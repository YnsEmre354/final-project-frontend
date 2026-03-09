import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_state.dart';
import 'package:state_notifier/state_notifier.dart';

class UserNotifier extends StateNotifier<UserState> {
  final StudentService _service;
  UserNotifier(this._service) : super(UserState());

  Future<void> logUser() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final logUser = await _service.getLogStudent();

      state = state.copyWith(isLoading: false, logUserDto: logUser!);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
