class UserAccountModel {
  const UserAccountModel({
    required this.id,
    required this.email,
    this.role,
    this.displayName,
    this.phone,
    this.avatarPath,
  });

  factory UserAccountModel.fromJson(Map<String, dynamic> json) =>
      UserAccountModel(
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

  @override
  bool operator ==(Object other) =>
      other is UserAccountModel &&
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

class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      AuthTokensModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresIn: (json['expiresIn'] as num).toInt(),
      );

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
      };
}

class AuthState {
  const AuthState({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.isLoading = false,
    this.errorMessage,
  });

  const AuthState.initial() : this();

  AuthState.loading({AuthState? previous})
      : this(
          user: previous?.user,
          accessToken: previous?.accessToken,
          refreshToken: previous?.refreshToken,
          isLoading: true,
        );

  const AuthState.authenticated({
    required UserAccountModel user,
    required String accessToken,
    required String refreshToken,
  }) : this(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isLoading: false,
        );

  const AuthState.unauthenticated({String? error})
      : this(
          user: null,
          accessToken: null,
          refreshToken: null,
          isLoading: false,
          errorMessage: error,
        );

  final UserAccountModel? user;
  final String? accessToken;
  final String? refreshToken;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null && accessToken != null;
}
