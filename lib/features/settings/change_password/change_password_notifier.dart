import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/change_password_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/change_password/change_password_state.dart';

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  final StudentService _service;

  ChangePasswordNotifier(this._service) : super(ChangePasswordState());

  Future<ChangePasswordResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _service.changePasswordStudent(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false);

      if (result == ChangePasswordResult.wrongPassword) {
        state = state.copyWith(error: "Eski şifre hatalı");
      }

      if (result == ChangePasswordResult.userNotFound) {
        state = state.copyWith(error: "Kullanıcı bulunamadı");
      }
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return ChangePasswordResult.error;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
