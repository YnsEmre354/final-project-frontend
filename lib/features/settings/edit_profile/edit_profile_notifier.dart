import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/change_username_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/delete_user_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/edit_profile/edit_profile_state.dart';

class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final StudentService _service;

  EditProfileNotifier(this._service) : super(EditProfileState());

  Future<ChangeUsernameResult> changeUsername({
    required String username,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _service.changeUsernameStudent(username: username);
      state = state.copyWith(isLoading: false);

      if (result == ChangeUsernameResult.usernameTaken) {
        state = state.copyWith(error: "Bu Kullanıcı Adı Zaten Alındı");
      }

      if (result == ChangeUsernameResult.userNotFound) {
        state = state.copyWith(error: "Kullanıcı Bulunamadı");
      }

      if (result == ChangeUsernameResult.noChange) {
        state = state.copyWith(error: "Kullanıcı Adı Zaten Aynı");
      }
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return ChangeUsernameResult.error;
    }
  }

  Future<DeleteUserResult> deleteUser() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _service.deleteStudent();
      state = state.copyWith(isLoading: false);

      if (result == DeleteUserResult.alreadyDeleted) {
        state = state.copyWith(error: "This User already deleted!");
      }

      if (result == DeleteUserResult.noDeleted) {
        state = state.copyWith(error: "This user cant delete!");
      }

      if (result == DeleteUserResult.userNotFound) {
        state = state.copyWith(error: "User not found");
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return DeleteUserResult.error;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
