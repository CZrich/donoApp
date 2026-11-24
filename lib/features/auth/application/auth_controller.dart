import 'package:alimentored/features/auth/data/auth_repository.dart';
import 'package:alimentored/features/auth/data/session_storage.dart';
import 'package:alimentored/features/auth/domain/auth_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  SessionStorage get _storage => ref.read(sessionStorageProvider);

  Future<void> initSession() async {
    try {
      final session = await _storage.getSession();
      if (session == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      state = AuthState.authenticated(
        user: session.user,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      // Verify token in background and update user data
      try {
        final freshUser = await _repository.getMe(session.accessToken);
        state = AuthState.authenticated(
          user: freshUser,
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
        await _storage.saveSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          user: freshUser,
        );
      } on AuthException catch (e) {
        if (e.statusCode == 401) {
          // Attempt refresh
          try {
            final newTokens = await _repository.refresh(session.refreshToken);
            final freshUser = await _repository.getMe(newTokens.accessToken);
            state = AuthState.authenticated(
              user: freshUser,
              accessToken: newTokens.accessToken,
              refreshToken: newTokens.refreshToken,
            );
            await _storage.saveSession(
              accessToken: newTokens.accessToken,
              refreshToken: newTokens.refreshToken,
              user: freshUser,
            );
          } catch (_) {
            await logout();
          }
        }
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading(previous: state);
    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );

      await _storage.saveSession(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
        user: result.user,
      );

      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading(previous: state);
    try {
      final result = await _repository.register(
        email: email,
        password: password,
      );

      await _storage.saveSession(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
        user: result.user,
      );

      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final currentRefreshToken = state.refreshToken;
    if (currentRefreshToken != null) {
      await _repository.logout(currentRefreshToken);
    }
    await _storage.clearSession();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
