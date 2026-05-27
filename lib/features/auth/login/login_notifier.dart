import 'package:flutter_turkce_ogrenme_application/data/enum/login_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/auth_storage.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_state.dart';
import 'package:state_notifier/state_notifier.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final StudentService _service;
  final AuthStorage _authStorage;

  LoginNotifier(this._service, this._authStorage) : super(LoginState());

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final (result, response) = await _service.loginStudent(
        email: email,
        password: password,
      );
      if (result == LoginResult.success && response != null) {
        // Token'ı kaydet
        await _authStorage.saveToken(response.token);

        // State'i başarılı olarak güncelle
        state = state.copyWith(isLoading: false, loginUser: response);
        return LoginResult.success;
      } else if (result == LoginResult.accountPassive) {
        state = state.copyWith(
          isLoading: false,
          error: "Hesabınız pasif durumdadır. Lütfen yönetici ile iletişime geçin.",
        );
        return LoginResult.accountPassive;
      } else if (result == LoginResult.invalidCredentials) {
        state = state.copyWith(
          isLoading: false,
          error: "E-posta veya şifre hatalı.",
        );
        return LoginResult.invalidCredentials;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Bir sunucu hatası oluştu.",
        );
        return LoginResult.error;
      }
    } catch (e) {
      // Beklenmedik bir hata (internet kesilmesi vb.)
      state = state.copyWith(isLoading: false, error: e.toString());
      return LoginResult.error;
    }
  }

  void loginClear() {
    state = state.copyWith(clearError: true);
  }
}
