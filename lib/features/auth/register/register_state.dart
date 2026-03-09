class RegisterState {
  final bool isLoading;
  // final RegisterUserDto? registerUser;
  final String? error;

  RegisterState({this.isLoading = false, /*this.registerUser,*/ this.error});

  RegisterState copyWith({
    bool? isLoading,
    // RegisterUserDto? registerUser,
    String? error,
    bool clearError = false,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      //   registerUser: registerUser ?? this.registerUser,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
