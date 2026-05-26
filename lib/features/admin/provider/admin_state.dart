import 'package:flutter_turkce_ogrenme_application/data/models/admin/admin_get_all_user_response_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/admin/admin_student_progress_response_dto.dart';

class AdminState {
  final bool isLoading;
  final String? error;
  final List<AdminGetAllUserResponseDto> users;
  final List<AdminStudentProgressResponseDto> selectedUserProgress;
  final bool isLoginSuccess;
  final bool isProgressLoading;

  AdminState({
    this.isLoading = false,
    this.error,
    this.users = const [],
    this.selectedUserProgress = const [],
    this.isLoginSuccess = false,
    this.isProgressLoading = true,
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    List<AdminGetAllUserResponseDto>? users,
    List<AdminStudentProgressResponseDto>? selectedUserProgress,
    bool? isLoginSuccess,
    bool? isProgressLoading,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // To allow resetting error, we can just pass error (or null)
      users: users ?? this.users,
      selectedUserProgress: selectedUserProgress ?? this.selectedUserProgress,
      isLoginSuccess: isLoginSuccess ?? this.isLoginSuccess,
      isProgressLoading: isProgressLoading ?? this.isProgressLoading,
    );
  }
}
