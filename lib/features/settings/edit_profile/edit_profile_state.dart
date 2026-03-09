class EditProfileState {
  bool isLoading;
  String? error;

  EditProfileState({this.isLoading = false, this.error});

  EditProfileState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
