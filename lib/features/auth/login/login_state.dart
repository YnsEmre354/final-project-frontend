import 'package:flutter_turkce_ogrenme_application/data/models/student/login_response_dto.dart';

class LoginState {
  final bool isLoading;
  final LoginResponseDto? loginUser;
  final String? error;

  LoginState({this.isLoading = false, this.loginUser, this.error});

  LoginState copyWith({
    bool? isLoading,
    LoginResponseDto? loginUser,
    String? error,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginUser: loginUser ?? this.loginUser,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
