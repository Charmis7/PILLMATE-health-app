import 'auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  // Loading state
  bool isLoading = false;

  // Sign up with email
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required Function(bool) onLoadingChanged,
  }) async {
    onLoadingChanged(true);
    isLoading = true;

    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );

    isLoading = false;
    onLoadingChanged(false);
    return result;
  }

  // Login with email
  Future<String?> login({
    required String email,
    required String password,
    required Function(bool) onLoadingChanged,
  }) async {
    onLoadingChanged(true);
    isLoading = true;

    final result = await _authService.login(
      email: email,
      password: password,
    );

    isLoading = false;
    onLoadingChanged(false);
    return result;
  }

  // Sign up with Google
  Future<String?> signUpWithGoogle({
    required Function(bool) onLoadingChanged,
  }) async {
    onLoadingChanged(true);
    isLoading = true;

    final result = await _authService.signUpWithGoogle();

    isLoading = false;
    onLoadingChanged(false);
    return result;
  }

  // Login with Google
  Future<String?> loginWithGoogle({
    required Function(bool) onLoadingChanged,
  }) async {
    onLoadingChanged(true);
    isLoading = true;

    final result = await _authService.loginWithGoogle();

    isLoading = false;
    onLoadingChanged(false);
    return result;
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
  }

  // Send password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }
}