class ChangePasswordState {
  bool isLoading;
  String? error;

  ChangePasswordState({this.isLoading = false, this.error});

  ChangePasswordState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
