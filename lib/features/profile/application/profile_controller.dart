import 'dart:async';

import 'package:alimentored/features/auth/application/auth_controller.dart';
import 'package:alimentored/features/auth/data/session_storage.dart';
import 'package:alimentored/features/auth/domain/auth_models.dart';
import 'package:alimentored/features/profile/data/profile_repository.dart';
import 'package:alimentored/features/profile/domain/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController extends AsyncNotifier<UserProfileModel> {
  @override
  FutureOr<UserProfileModel> build() async {
    final authState = ref.watch(authControllerProvider);
    final token = authState.accessToken;
    if (token == null) {
      throw StateError('Usuario no autenticado');
    }
    return ref.read(profileRepositoryProvider).getProfile(token);
  }

  Future<bool> updateProfile({
    String? displayName,
    String? phone,
    String? avatarPath,
    String? role,
  }) async {
    final authState = ref.read(authControllerProvider);
    final token = authState.accessToken;
    if (token == null) return false;

    state = const AsyncLoading();
    try {
      final updated = await ref.read(profileRepositoryProvider).updateProfile(
            accessToken: token,
            displayName: displayName,
            phone: phone,
            avatarPath: avatarPath,
            role: role,
          );

      state = AsyncData(updated);

      // Keep AuthState and SessionStorage in sync
      final currentAuthUser = authState.user;
      if (currentAuthUser != null) {
        final syncedUser = UserAccountModel(
          id: updated.id,
          email: updated.email,
          role: updated.role,
          displayName: updated.displayName,
          phone: updated.phone,
          avatarPath: updated.avatarPath,
        );

        await ref.read(sessionStorageProvider).saveSession(
              accessToken: token,
              refreshToken: authState.refreshToken ?? '',
              user: syncedUser,
            );
      }
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> reload() async {
    final authState = ref.read(authControllerProvider);
    final token = authState.accessToken;
    if (token == null) return;

    state = const AsyncLoading();
    try {
      final profile =
          await ref.read(profileRepositoryProvider).getProfile(token);
      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfileModel>(
  ProfileController.new,
);
