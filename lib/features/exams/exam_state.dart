class ExamState {
  final bool isLoading;
  final List<dynamic> questions;
  final int currentIndex;
  final int totalQuestions;
  final int correctAnswers;
  final String? error;
  final double? aiAccuracy;

  ExamState({
    this.isLoading = false,
    this.questions = const [],
    this.currentIndex = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.error,
    this.aiAccuracy,
  });

  ExamState copyWith({
    bool? isLoading,
    List<dynamic>? questions,
    int? currentIndex,
    int? totalQuestions,
    int? correctAnswers,
    String? error,
    double? aiAccuracy,
    bool clearError = false,
  }) {
    return ExamState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      error: clearError ? null : (error ?? this.error),
      aiAccuracy: aiAccuracy ?? this.aiAccuracy,
    );
  }
}
