import 'package:postgres/postgres.dart';

import 'profile_repository.dart';

class PostgresProfileRepository implements ProfileRepository {
  const PostgresProfileRepository(this.database);

  final Pool database;

  @override
  Future<UserProfile?> findById(String id) async {
    final result = await database.execute(
      Sql.named('''
        SELECT id, email, role::text as role, display_name, phone, avatar_path,
               created_at, updated_at
        FROM profiles
        WHERE id = @id:uuid
        LIMIT 1
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return _profileFrom(result.first.toColumnMap());
  }

  @override
  Future<UserProfile> update({
    required String id,
    String? displayName,
    String? phone,
    String? avatarPath,
    String? role,
  }) async {
    final result = await database.execute(
      Sql.named('''
        UPDATE profiles
        SET display_name = COALESCE(@display_name, display_name),
            phone = COALESCE(@phone, phone),
            avatar_path = COALESCE(@avatar_path, avatar_path),
            role = CASE
              WHEN role IS NULL AND @role IS NOT NULL THEN @role::user_role
              ELSE role
            END,
            updated_at = now()
        WHERE id = @id:uuid
        RETURNING id, email, role::text as role, display_name, phone, avatar_path,
                  created_at, updated_at
      '''),
      parameters: {
        'id': id,
        'display_name': displayName?.trim(),
        'phone': phone?.trim(),
        'avatar_path': avatarPath,
        'role': role,
      },
    );

    if (result.isEmpty) {
      throw StateError('Profile not found for id $id');
    }
    return _profileFrom(result.single.toColumnMap());
  }

  UserProfile _profileFrom(Map<String, Object?> row) => UserProfile(
        id: row['id'].toString(),
        email: row['email']! as String,
        role: row['role'] as String?,
        displayName: row['display_name'] as String?,
        phone: row['phone'] as String?,
        avatarPath: row['avatar_path'] as String?,
        createdAt: (row['created_at'] as DateTime?)?.toUtc(),
        updatedAt: (row['updated_at'] as DateTime?)?.toUtc(),
      );
}
