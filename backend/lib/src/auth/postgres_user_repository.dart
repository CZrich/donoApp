import 'package:postgres/postgres.dart';

import 'user_repository.dart';

class PostgresUserRepository implements UserRepository {
  const PostgresUserRepository(this.database);

  final Session database;

  @override
  Future<UserAccount?> findByEmail(String email) async {
    final result = await database.execute(
      Sql.named('''
        SELECT id, email, password_hash
        FROM accounts
        WHERE email = @email
        LIMIT 1
      '''),
      parameters: {'email': email},
    );

    if (result.isEmpty) return null;
    return _accountFrom(result.first.toColumnMap());
  }

  @override
  Future<UserAccount> create({
    required String email,
    required String passwordHash,
  }) async {
    try {
      final result = await database.execute(
        Sql.named('''
          INSERT INTO accounts (email, password_hash)
          VALUES (@email, @password_hash)
          RETURNING id, email, password_hash
        '''),
        parameters: {'email': email, 'password_hash': passwordHash},
      );
      return _accountFrom(result.single.toColumnMap());
    } on UniqueViolationException {
      throw const DuplicateEmail();
    }
  }

  UserAccount _accountFrom(Map<String, Object?> row) => UserAccount(
    id: row['id'].toString(),
    email: row['email']! as String,
    passwordHash: row['password_hash']! as String,
  );
}
