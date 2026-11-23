import 'dart:io';

import 'package:postgres/postgres.dart';

Future<void> runMigrations(Pool database, Directory directory) async {
  if (!await directory.exists()) {
    throw StateError('Migration directory does not exist: ${directory.path}');
  }

  await database.execute('''
    CREATE TABLE IF NOT EXISTS schema_migrations (
      name text PRIMARY KEY,
      applied_at timestamptz NOT NULL DEFAULT now()
    )
  ''');

  final migrations = await directory
      .list()
      .where((entry) => entry is File && entry.path.endsWith('.sql'))
      .cast<File>()
      .toList();
  migrations.sort((left, right) => left.path.compareTo(right.path));

  for (final migration in migrations) {
    final name = migration.uri.pathSegments.last;
    final sql = await migration.readAsString();
    await database.runTx((transaction) async {
      await transaction.execute(
        Sql.named('SELECT pg_advisory_xact_lock(hashtext(@name))'),
        parameters: {'name': name},
      );
      final applied = await transaction.execute(
        Sql.named('SELECT 1 FROM schema_migrations WHERE name = @name'),
        parameters: {'name': name},
      );
      if (applied.isNotEmpty) return;

      await transaction.execute(sql, queryMode: QueryMode.simple);
      await transaction.execute(
        Sql.named('INSERT INTO schema_migrations (name) VALUES (@name)'),
        parameters: {'name': name},
      );
    });
  }
}
