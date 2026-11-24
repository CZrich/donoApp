class UserAccount {
  const UserAccount({
    required this.id,
    required this.email,
    required this.passwordHash,
    this.role,
    this.displayName,
    this.phone,
    this.avatarPath,
  });

  final String id;
  final String email;
  final String passwordHash;
  final String? role;
  final String? displayName;
  final String? phone;
  final String? avatarPath;

  @override
  bool operator ==(Object other) =>
      other is UserAccount &&
      other.id == id &&
      other.email == email &&
      other.passwordHash == passwordHash &&
      other.role == role &&
      other.displayName == displayName &&
      other.phone == phone &&
      other.avatarPath == avatarPath;

  @override
  int get hashCode => Object.hash(
        id,
        email,
        passwordHash,
        role,
        displayName,
        phone,
        avatarPath,
      );
}

abstract interface class UserRepository {
  Future<UserAccount?> findByEmail(String email);

  Future<UserAccount?> findById(String id);

  Future<UserAccount> create({
    required String email,
    required String passwordHash,
  });
}

class InMemoryUserRepository implements UserRepository {
  final Map<String, UserAccount> _users = {};
  var _nextId = 0;

  @override
  Future<UserAccount?> findByEmail(String email) async => _users[email];

  @override
  Future<UserAccount?> findById(String id) async {
    for (final account in _users.values) {
      if (account.id == id) return account;
    }
    return null;
  }

  @override
  Future<UserAccount> create({
    required String email,
    required String passwordHash,
  }) async {
    if (_users.containsKey(email)) throw const DuplicateEmail();
    final account = UserAccount(
      id: (++_nextId).toString(),
      email: email,
      passwordHash: passwordHash,
    );
    _users[email] = account;
    return account;
  }
}

class DuplicateEmail implements Exception {
  const DuplicateEmail();
}
