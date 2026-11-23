import 'dart:io';

import 'package:alimentored_api/src/auth/postgres_user_repository.dart';
import 'package:alimentored_api/src/auth/user_repository.dart';
import 'package:alimentored_api/src/database/migrations.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

void main() {
  final port = int.tryParse(Platform.environment['TEST_DB_PORT'] ?? '');

  test(
    'persists accounts and translates duplicate emails',
    () async {
      final connection = _openPool(port!);
      addTearDown(connection.close);
      await _resetDatabase(connection);

      final schema = await File('../database/init/001_schema.sql')
          .readAsString();
      await connection.execute(schema, queryMode: QueryMode.simple);
      final repository = PostgresUserRepository(connection);

      final created = await repository.create(
        email: 'person@example.com',
        passwordHash: 'hash',
      );

      expect(created.id, isNotEmpty);
      expect(await repository.findByEmail('person@example.com'), created);
      await expectLater(
        repository.create(
          email: 'person@example.com',
          passwordHash: 'other-hash',
        ),
        throwsA(isA<DuplicateEmail>()),
      );
    },
    skip: port == null
        ? 'Set TEST_DB_PORT to run PostgreSQL integration.'
        : false,
  );

  test(
    'migrates legacy profiles without losing identity or references',
    () async {
      final connection = _openPool(port!);
      addTearDown(connection.close);
      await _resetDatabase(connection);
      final legacy = await File('test/fixtures/legacy_identity_schema.sql')
          .readAsString();
      await connection.execute(legacy, queryMode: QueryMode.simple);
      final seeded = await connection.execute('''
        WITH profile AS (
          INSERT INTO profiles (
            email, password_hash, role, display_name, phone
          ) VALUES (
            'legacy@example.com', 'legacy-hash', 'donor', 'Legacy', '555'
          ) RETURNING id
        ), organization AS (
          INSERT INTO organizations (profile_id)
          SELECT id FROM profile
          RETURNING profile_id
        ), donation AS (
          INSERT INTO donations (donor_id)
          SELECT id FROM profile
          RETURNING id
        )
        INSERT INTO reservations (donation_id, organization_id)
        SELECT donation.id, organization.profile_id
        FROM donation, organization
        RETURNING id
      ''');

      final migrations = Directory('../database/migrations');
      await Future.wait([
        runMigrations(connection, migrations),
        runMigrations(connection, migrations),
      ]);
      await runMigrations(connection, migrations);

      final repository = PostgresUserRepository(connection);
      final account = await repository.findByEmail('legacy@example.com');
      final references = await connection.execute('''
        SELECT count(*) AS count
        FROM reservations r
        JOIN donations d ON d.id = r.donation_id
        JOIN organizations o ON o.profile_id = r.organization_id
        JOIN profiles p ON p.id = o.profile_id
        JOIN accounts a ON a.id = p.id
      ''');

      expect(seeded, hasLength(1));
      expect(account?.passwordHash, 'legacy-hash');
      expect(references.single.toColumnMap()['count'], 1);
      final legacyCredentials = await connection.execute(
        'SELECT email, password_hash FROM profiles',
      );
      expect(legacyCredentials.single[0], 'legacy@example.com');
      expect(legacyCredentials.single[1], 'legacy-hash');
    },
    skip: port == null
        ? 'Set TEST_DB_PORT to run PostgreSQL integration.'
        : false,
  );
}

Pool<void> _openPool(int port) => Pool.withEndpoints([
  Endpoint(
    host: Platform.environment['TEST_DB_HOST'] ?? 'localhost',
    port: port,
    database: Platform.environment['TEST_DB_NAME'] ?? 'alimentored',
    username: Platform.environment['TEST_DB_USER'] ?? 'alimentored',
    password: Platform.environment['TEST_DB_PASSWORD'] ?? 'alimentored_test',
  ),
], settings: const PoolSettings(sslMode: SslMode.disable));

Future<void> _resetDatabase(Session database) => database.execute(
  'DROP SCHEMA public CASCADE; CREATE SCHEMA public',
  queryMode: QueryMode.simple,
);
