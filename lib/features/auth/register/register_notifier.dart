import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/register_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/register/register_state.dart';

class RegisterNotifier extends StateNotifier<RegisterState> {
  final StudentService _service;

  RegisterNotifier(this._service) : super(RegisterState());

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
      state = state.copyWith(isLoading: true, error: null);

      final result = await _service.registerStudent(
        name: name,
        surname: surname,
        username: username,
        email: email,
        password: password,
        nativeLanguage: nativeLanguage,
        gender: gender,
      );
      state = state.copyWith(isLoading: false);

      if (result == RegisterEnumResult.emailTaken) {
        state = state.copyWith(error: "Bu Email Adresi Zaten Kayitli!");
      } else if (result == RegisterEnumResult.usernameTaken) {
        state = state.copyWith(error: "Bu Kullanici Adi Zaten Kayitli!");
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return RegisterEnumResult.error;
    }
  }

  void registerClear() {
    state = state.copyWith(clearError: true);
  }
}
