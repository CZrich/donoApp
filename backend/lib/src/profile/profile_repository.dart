class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.role,
    this.displayName,
    this.phone,
    this.avatarPath,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? role;
  final String? displayName;
  final String? phone;
  final String? avatarPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'displayName': displayName,
        'phone': phone,
        'avatarPath': avatarPath,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.id == id &&
      other.email == email &&
      other.role == role &&
      other.displayName == displayName &&
      other.phone == phone &&
      other.avatarPath == avatarPath;

  @override
  int get hashCode =>
      Object.hash(id, email, role, displayName, phone, avatarPath);
}

abstract interface class ProfileRepository {
  Future<UserProfile?> findById(String id);

  Future<UserProfile> update({
    required String id,
    String? displayName,
    String? phone,
    String? avatarPath,
    String? role,
  });
}

class InMemoryProfileRepository implements ProfileRepository {
  final Map<String, UserProfile> _profiles = {};

  void seed(UserProfile profile) {
    _profiles[profile.id] = profile;
  }

  @override
  Future<UserProfile?> findById(String id) async => _profiles[id];

  @override
  Future<UserProfile> update({
    required String id,
    String? displayName,
    String? phone,
    String? avatarPath,
    String? role,
  }) async {
    final existing = _profiles[id];
    if (existing == null) {
      throw StateError('Profile not found for id $id');
    }

    final updated = UserProfile(
      id: existing.id,
      email: existing.email,
      // Protect existing role: only set if currently null
      role: existing.role ?? role,
      displayName: displayName ?? existing.displayName,
      phone: phone ?? existing.phone,
      // Keep previous avatar if not provided
      avatarPath: avatarPath ?? existing.avatarPath,
      createdAt: existing.createdAt ?? DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    _profiles[id] = updated;
    return updated;
  }
}
