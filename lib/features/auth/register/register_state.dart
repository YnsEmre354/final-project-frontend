class RegisterState {
  final bool isLoading;
  final String? error;
  /// Carries form data after Firebase user creation so the email-verification
  /// screen can finalize backend registration without re-asking the user.
  final Map<String, String>? pendingUserData;

  RegisterState({
    this.isLoading = false,
    this.error,
    this.pendingUserData,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    Map<String, String>? pendingUserData,
    bool clearPendingUserData = false,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pendingUserData: clearPendingUserData
          ? null
          : (pendingUserData ?? this.pendingUserData),
    );
  }
}
