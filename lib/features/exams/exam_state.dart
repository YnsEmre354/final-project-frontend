import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_evaluation_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_evaluation_dto.dart';

class ExamState {
  final bool isLoading;
  final List<dynamic> questions;
  final int currentIndex;
  final int totalQuestions;
  final int correctAnswers;
  final String? error;
  final double? aiAccuracy;
  /// Cache: soru ID -> soru verisi (önceki sorulara dönebilmek için)
  final Map<int, dynamic> visitedQuestions;
  /// Cache: soru ID -> kullanıcının verdiği cevap
  final Map<int, String> givenAnswers;
  /// Cache: soru ID -> değerlendirme sonucu (Writing)
  final Map<int, WritingEvaluationDto> writingEvaluations;
  /// Cache: soru ID -> değerlendirme sonucu (Speaking)
  final Map<int, SpeakingEvaluationDto> speakingEvaluations;
  /// Sınavın bittiğini gösteren bayrak
  final bool isExamFinished;

  ExamState({
    this.isLoading = false,
    this.questions = const [],
    this.currentIndex = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.error,
    this.aiAccuracy,
    this.visitedQuestions = const {},
    this.givenAnswers = const {},
    this.writingEvaluations = const {},
    this.speakingEvaluations = const {},
    this.isExamFinished = false,
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
    Map<int, dynamic>? visitedQuestions,
    Map<int, String>? givenAnswers,
    Map<int, WritingEvaluationDto>? writingEvaluations,
    Map<int, SpeakingEvaluationDto>? speakingEvaluations,
    bool? isExamFinished,
  }) {
    return ExamState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      error: clearError ? null : (error ?? this.error),
      aiAccuracy: aiAccuracy ?? this.aiAccuracy,
      visitedQuestions: visitedQuestions ?? this.visitedQuestions,
      givenAnswers: givenAnswers ?? this.givenAnswers,
      writingEvaluations: writingEvaluations ?? this.writingEvaluations,
      speakingEvaluations: speakingEvaluations ?? this.speakingEvaluations,
      isExamFinished: isExamFinished ?? this.isExamFinished,
    );
  }
}
