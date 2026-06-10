import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/login_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/auth_storage.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/firebase_auth_service.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_state.dart';
import 'package:state_notifier/state_notifier.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final StudentService _service;
  final AuthStorage _authStorage;
  final FirebaseAuthService _firebaseAuth;

  LoginNotifier(this._service, this._authStorage)
      : _firebaseAuth = FirebaseAuthService(),
        super(LoginState());

  /// Firebase login flow:
  /// 1. Sign in to Firebase with email + password.
  /// 2. Check emailVerified — reject if not verified.
  /// 3. Get Firebase ID token.
  /// 4. Exchange ID token for backend JWT via /api/Student/firebase-login.
  /// 5. Store backend JWT in flutter_secure_storage.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Step 1: Firebase sign-in
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Check email verification
      if (credential.user?.emailVerified != true) {
        state = state.copyWith(
          isLoading: false,
          error: 'E-posta adresiniz henüz doğrulanmamış. '
              'Lütfen gelen kutunuzu kontrol edin.',
        );
        return LoginResult.emailNotVerified;
      }

      // Step 3: Get Firebase ID token
      final idToken = await credential.user?.getIdToken();
      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Firebase token alınamadı.',
        );
        return LoginResult.error;
      }

      // Step 4: Exchange for backend JWT
      final (result, response) = await _service.firebaseLogin(idToken);

      if (result == LoginResult.success && response != null) {
        await _authStorage.saveToken(response.token);
        state = state.copyWith(isLoading: false, loginUser: response);
        return LoginResult.success;
      } else if (result == LoginResult.accountPassive) {
        state = state.copyWith(
          isLoading: false,
          error: 'Hesabınız pasif durumdadır. Lütfen yönetici ile iletişime geçin.',
        );
        return LoginResult.accountPassive;
      } else if (result == LoginResult.emailNotVerified) {
        state = state.copyWith(
          isLoading: false,
          error: 'E-posta adresiniz henüz doğrulanmamış.',
        );
        return LoginResult.emailNotVerified;
      } else if (result == LoginResult.invalidCredentials) {
        state = state.copyWith(
          isLoading: false,
          error: 'Bu e-posta ile kayıtlı bir hesap bulunamadı.',
        );
        return LoginResult.invalidCredentials;
      } else {
        state = state.copyWith(isLoading: false, error: 'Bir sunucu hatası oluştu.');
        return LoginResult.error;
      }
    } on FirebaseAuthException catch (e) {
      final message = FirebaseAuthService.turkishErrorMessage(e);
      state = state.copyWith(isLoading: false, error: message);
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return LoginResult.invalidCredentials;
      }
      return LoginResult.error;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return LoginResult.error;
    }
  }

  void loginClear() {
    state = state.copyWith(clearError: true);
  }
}
