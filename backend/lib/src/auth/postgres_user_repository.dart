import 'package:postgres/postgres.dart';

import 'user_repository.dart';

class PostgresUserRepository implements UserRepository {
  const PostgresUserRepository(this.database);

  final Pool database;

  @override
  Future<UserAccount?> findByEmail(String email) async {
    final result = await database.execute(
      Sql.named('''
        SELECT a.id, a.email, a.password_hash,
               p.role::text as role, p.display_name, p.phone, p.avatar_path
        FROM accounts a
        LEFT JOIN profiles p ON p.id = a.id
        WHERE a.email = @email
        LIMIT 1
      '''),
      parameters: {'email': email},
    );

    if (result.isEmpty) return null;
    return _accountFrom(result.first.toColumnMap());
  }

  @override
  Future<UserAccount?> findById(String id) async {
    final result = await database.execute(
      Sql.named('''
        SELECT a.id, a.email, a.password_hash,
               p.role::text as role, p.display_name, p.phone, p.avatar_path
        FROM accounts a
        LEFT JOIN profiles p ON p.id = a.id
        WHERE a.id = @id:uuid
        LIMIT 1
      '''),
      parameters: {'id': id},
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
      return await database.runTx((transaction) async {
        final result = await transaction.execute(
          Sql.named('''
            INSERT INTO accounts (email, password_hash)
            VALUES (@email, @password_hash)
            RETURNING id, email, password_hash
          '''),
          parameters: {'email': email, 'password_hash': passwordHash},
        );
        final account = _accountFrom(result.single.toColumnMap());
        await transaction.execute(
          Sql.named('''
            INSERT INTO profiles (id, email, password_hash)
            VALUES (@id:uuid, @email, @password_hash)
          '''),
          parameters: {
            'id': account.id,
            'email': account.email,
            'password_hash': account.passwordHash,
          },
        );
        return account;
      });
    } on UniqueViolationException {
      throw const DuplicateEmail();
    }
  }

  UserAccount _accountFrom(Map<String, Object?> row) => UserAccount(
    id: row['id'].toString(),
    email: row['email']! as String,
    passwordHash: row['password_hash']! as String,
    role: row['role'] as String?,
    displayName: row['display_name'] as String?,
    phone: row['phone'] as String?,
    avatarPath: row['avatar_path'] as String?,
  );
}
