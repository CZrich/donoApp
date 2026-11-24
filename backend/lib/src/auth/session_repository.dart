import 'package:postgres/postgres.dart';

class AuthSession {
  const AuthSession({
    required this.id,
    required this.accountId,
    required this.refreshTokenHash,
    required this.expiresAt,
    required this.createdAt,
  });

  final String id;
  final String accountId;
  final String refreshTokenHash;
  final DateTime expiresAt;
  final DateTime createdAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  @override
  bool operator ==(Object other) =>
      other is AuthSession &&
      other.id == id &&
      other.accountId == accountId &&
      other.refreshTokenHash == refreshTokenHash;

  @override
  int get hashCode => Object.hash(id, accountId, refreshTokenHash);
}

abstract interface class SessionRepository {
  Future<AuthSession> createSession({
    required String accountId,
    required String refreshTokenHash,
    required DateTime expiresAt,
  });

  Future<AuthSession?> findValidSession(String refreshTokenHash);

  Future<void> deleteSession(String refreshTokenHash);

  Future<void> deleteSessionsForAccount(String accountId);
}

class InMemorySessionRepository implements SessionRepository {
  final Map<String, AuthSession> _sessions = {};
  var _nextId = 0;

  @override
  Future<AuthSession> createSession({
    required String accountId,
    required String refreshTokenHash,
    required DateTime expiresAt,
  }) async {
    final session = AuthSession(
      id: (++_nextId).toString(),
      accountId: accountId,
      refreshTokenHash: refreshTokenHash,
      expiresAt: expiresAt,
      createdAt: DateTime.now().toUtc(),
    );
    _sessions[refreshTokenHash] = session;
    return session;
  }

  @override
  Future<AuthSession?> findValidSession(String refreshTokenHash) async {
    final session = _sessions[refreshTokenHash];
    if (session == null || session.isExpired) return null;
    return session;
  }

  @override
  Future<void> deleteSession(String refreshTokenHash) async {
    _sessions.remove(refreshTokenHash);
  }

  @override
  Future<void> deleteSessionsForAccount(String accountId) async {
    _sessions.removeWhere((_, session) => session.accountId == accountId);
  }
}

class PostgresSessionRepository implements SessionRepository {
  const PostgresSessionRepository(this.database);

  final Pool database;

  @override
  Future<AuthSession> createSession({
    required String accountId,
    required String refreshTokenHash,
    required DateTime expiresAt,
  }) async {
    final result = await database.execute(
      Sql.named('''
        INSERT INTO sessions (account_id, refresh_token_hash, expires_at)
        VALUES (@account_id:uuid, @refresh_token_hash, @expires_at)
        RETURNING id, account_id, refresh_token_hash, expires_at, created_at
      '''),
      parameters: {
        'account_id': accountId,
        'refresh_token_hash': refreshTokenHash,
        'expires_at': expiresAt,
      },
    );

    return _sessionFrom(result.single.toColumnMap());
  }

  @override
  Future<AuthSession?> findValidSession(String refreshTokenHash) async {
    final result = await database.execute(
      Sql.named('''
        SELECT id, account_id, refresh_token_hash, expires_at, created_at
        FROM sessions
        WHERE refresh_token_hash = @refresh_token_hash
          AND expires_at > now()
        LIMIT 1
      '''),
      parameters: {'refresh_token_hash': refreshTokenHash},
    );

    if (result.isEmpty) return null;
    return _sessionFrom(result.first.toColumnMap());
  }

  @override
  Future<void> deleteSession(String refreshTokenHash) async {
    await database.execute(
      Sql.named('''
        DELETE FROM sessions
        WHERE refresh_token_hash = @refresh_token_hash
      '''),
      parameters: {'refresh_token_hash': refreshTokenHash},
    );
  }

  @override
  Future<void> deleteSessionsForAccount(String accountId) async {
    await database.execute(
      Sql.named('''
        DELETE FROM sessions
        WHERE account_id = @account_id:uuid
      '''),
      parameters: {'account_id': accountId},
    );
  }

  AuthSession _sessionFrom(Map<String, Object?> row) => AuthSession(
        id: row['id'].toString(),
        accountId: row['account_id'].toString(),
        refreshTokenHash: row['refresh_token_hash']! as String,
        expiresAt: (row['expires_at']! as DateTime).toUtc(),
        createdAt: (row['created_at']! as DateTime).toUtc(),
      );
}
