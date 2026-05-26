import 'package:flutter_turkce_ogrenme_application/data/models/student/log_user_dto.dart';

class UserState {
  final bool isLoading;
  final LogUserDto? logUserDto;
  final String? error;

  UserState({this.isLoading = false, this.logUserDto, this.error});

  UserState copyWith({
    bool? isLoading,
    LogUserDto? logUserDto,
    String? error,
    bool clearError = false,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      logUserDto: logUserDto ?? this.logUserDto,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
