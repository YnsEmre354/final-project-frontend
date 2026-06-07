import 'package:flutter_turkce_ogrenme_application/data/models/listening/listening_content_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/reading/reading_content_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_content_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_task_dto.dart';

enum PlacementStep {
  reading,
  listening,
  writing,
  speaking,
  saving,
  result,
}

class PlacementState {
  final PlacementStep currentStep;
  final int currentQuestionIndex; // 1 to 3 for reading/listening, 1 for writing/speaking
  final bool isLoading;
  final String? error;

  // Data
  final ReadingContentDto? currentReading;
  final ListeningContentDto? currentListening;
  final WritingTaskDto? currentWriting;
  final SpeakingContentDto? currentSpeaking;

  // Answers & Scores
  final Map<int, String> readingAnswers;
  final Map<int, String> listeningAnswers;
  final int writingScore;
  final int speakingScore;
  final String determinedLevel;

  PlacementState({
    this.currentStep = PlacementStep.reading,
    this.currentQuestionIndex = 1,
    this.isLoading = false,
    this.error,
    this.currentReading,
    this.currentListening,
    this.currentWriting,
    this.currentSpeaking,
    this.readingAnswers = const {},
    this.listeningAnswers = const {},
    this.writingScore = 0,
    this.speakingScore = 0,
    this.determinedLevel = 'A1',
  });

  PlacementState copyWith({
    PlacementStep? currentStep,
    int? currentQuestionIndex,
    bool? isLoading,
    String? error,
    bool clearError = false,
    ReadingContentDto? currentReading,
    ListeningContentDto? currentListening,
    WritingTaskDto? currentWriting,
    SpeakingContentDto? currentSpeaking,
    Map<int, String>? readingAnswers,
    Map<int, String>? listeningAnswers,
    int? writingScore,
    int? speakingScore,
    String? determinedLevel,
  }) {
    return PlacementState(
      currentStep: currentStep ?? this.currentStep,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentReading: currentReading ?? this.currentReading,
      currentListening: currentListening ?? this.currentListening,
      currentWriting: currentWriting ?? this.currentWriting,
      currentSpeaking: currentSpeaking ?? this.currentSpeaking,
      readingAnswers: readingAnswers ?? this.readingAnswers,
      listeningAnswers: listeningAnswers ?? this.listeningAnswers,
      writingScore: writingScore ?? this.writingScore,
      speakingScore: speakingScore ?? this.speakingScore,
      determinedLevel: determinedLevel ?? this.determinedLevel,
    );
  }
}
