class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    this.role,
    this.displayName,
    this.phone,
    this.avatarPath,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'] as String,
        email: json['email'] as String,
        role: json['role'] as String?,
        displayName: json['displayName'] as String?,
        phone: json['phone'] as String?,
        avatarPath: json['avatarPath'] as String?,
      );

  final String id;
  final String email;
  final String? role;
  final String? displayName;
  final String? phone;
  final String? avatarPath;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'displayName': displayName,
        'phone': phone,
        'avatarPath': avatarPath,
      };

  UserProfileModel copyWith({
    String? displayName,
    String? phone,
    String? avatarPath,
    String? role,
  }) {
    return UserProfileModel(
      id: id,
      email: email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfileModel &&
      other.id == id &&
      other.email == email &&
      other.role == role &&
      other.displayName == displayName &&
      other.phone == phone &&
      other.avatarPath == avatarPath;

  @override
  int get hashCode => Object.hash(
        id,
        email,
        role,
        displayName,
        phone,
        avatarPath,
      );
}
