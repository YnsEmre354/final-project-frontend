import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/register_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/firebase_auth_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/register/register_state.dart';

class RegisterNotifier extends StateNotifier<RegisterState> {
  final FirebaseAuthService _firebaseAuth;

  RegisterNotifier(this._firebaseAuth) : super(RegisterState());

  /// Firebase register flow:
  /// 1. Create Firebase user with email + password.
  /// 2. Send email verification.
  /// 3. Cache form data in state.pendingUserData.
  /// 4. Return emailVerificationSent — screen navigates to EmailVerificationScreen.
  Future<RegisterEnumResult> register({
    required String name,
    required String surname,
    required String username,
    required String email,
    required String password,
    required String nativeLanguage,
    required String gender,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await _firebaseAuth.createUserAndSendVerification(
        email: email,
        password: password,
      );

      // Store form data so EmailVerificationScreen can complete backend registration
      state = state.copyWith(
        isLoading: false,
        pendingUserData: {
          'name': name,
          'surname': surname,
          'username': username,
          'email': email,
          'nativeLanguage': nativeLanguage,
          'gender': gender,
        },
      );

      return RegisterEnumResult.emailVerificationSent;
    } on FirebaseAuthException catch (e) {
      final message = FirebaseAuthService.turkishErrorMessage(e);
      state = state.copyWith(isLoading: false, error: message);

      if (e.code == 'email-already-in-use') {
        return RegisterEnumResult.emailTaken;
      }
      return RegisterEnumResult.error;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return RegisterEnumResult.error;
    }
  }

  void registerClear() {
    state = state.copyWith(clearError: true);
  }
}
