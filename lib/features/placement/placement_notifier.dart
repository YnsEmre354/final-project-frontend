import 'package:flutter_turkce_ogrenme_application/data/models/general_student_submit_rl_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/general_student_submit_ws_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_evaluation_request_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/post_user_skill_enrollment_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_evaluation_request_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/ai_service.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_state.dart';
import 'package:state_notifier/state_notifier.dart';

class PlacementNotifier extends StateNotifier<PlacementState> {
  final AiService _aiService;
  final StudentService _studentService;

  PlacementNotifier(this._aiService, this._studentService)
    : super(PlacementState()) {
    _loadCurrentQuestion();
  }

  Future<void> _loadCurrentQuestion() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (state.currentStep == PlacementStep.reading) {
        final q = await _aiService.getReading('B2', state.currentQuestionIndex);
        if (q != null) {
          state = state.copyWith(currentReading: q, isLoading: false);
        } else {
          state = state.copyWith(error: 'Soru getirilemedi', isLoading: false);
        }
      } else if (state.currentStep == PlacementStep.listening) {
        final q = await _aiService.getListening(
          'B2',
          state.currentQuestionIndex,
        );
        if (q != null) {
          state = state.copyWith(currentListening: q, isLoading: false);
        } else {
          state = state.copyWith(error: 'Soru getirilemedi', isLoading: false);
        }
      } else if (state.currentStep == PlacementStep.writing) {
        final q = await _aiService.getWriting('B2', 1);
        if (q != null) {
          state = state.copyWith(currentWriting: q, isLoading: false);
        } else {
          state = state.copyWith(error: 'Soru getirilemedi', isLoading: false);
        }
      } else if (state.currentStep == PlacementStep.speaking) {
        final q = await _aiService.getSpeaking('B2', 1);
        if (q != null) {
          state = state.copyWith(currentSpeaking: q, isLoading: false);
        } else {
          state = state.copyWith(error: 'Soru getirilemedi', isLoading: false);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void answerReading(String answer) {
    final updated = Map<int, String>.from(state.readingAnswers);
    updated[state.currentQuestionIndex] = answer;
    state = state.copyWith(readingAnswers: updated);
  }

  void answerListening(String answer) {
    final updated = Map<int, String>.from(state.listeningAnswers);
    updated[state.currentQuestionIndex] = answer;
    state = state.copyWith(listeningAnswers: updated);
  }

  Future<void> nextStep() async {
    if (state.currentStep == PlacementStep.reading) {
      final totalReadingQuestions = state.currentReading?.questions.length ?? 3;
      if (state.currentQuestionIndex < totalReadingQuestions) {
        state = state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex + 1,
        );
      } else {
        state = state.copyWith(
          currentStep: PlacementStep.listening,
          currentQuestionIndex: 1,
        );
        await _loadCurrentQuestion();
      }
    } else if (state.currentStep == PlacementStep.listening) {
      final totalListeningQuestions =
          state.currentListening?.questions.length ?? 3;
      if (state.currentQuestionIndex < totalListeningQuestions) {
        state = state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex + 1,
        );
      } else {
        state = state.copyWith(
          currentStep: PlacementStep.writing,
          currentQuestionIndex: 1,
        );
        await _loadCurrentQuestion();
      }
    }
  }

  Future<void> submitWriting(String userText) async {
    if (state.currentWriting == null) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final dto = WritingEvaluationRequestDto(
      level: 'B2', // B2 kriterlerine göre değerlendirilir
      userText: userText,
      topic: state.currentWriting!.title,
      instructions: state.currentWriting!.instructions,
    );

    final result = await _aiService.evaluationWriting(dto);
    if (result != null) {
      state = state.copyWith(
        writingScore: result.score,
        currentStep: PlacementStep.speaking,
        currentQuestionIndex: 1,
        isLoading: false,
      );
      await _loadCurrentQuestion();
    } else {
      state = state.copyWith(
        error: 'Değerlendirme yapılamadı',
        isLoading: false,
      );
    }
  }

  Future<void> submitSpeaking(String audioPath) async {
    if (state.currentSpeaking == null) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final dto = SpeakingEvaluationRequestDto(
      level: 'B2', // B2 kriterlerine göre değerlendirilir
      topic: state.currentSpeaking!.title,
      instructions: state.currentSpeaking!.instructions,
      audioFilePath: audioPath,
    );

    final result = await _aiService.evaluateSpeaking(dto);
    if (result != null) {
      state = state.copyWith(
        speakingScore: result.score,
        currentStep: PlacementStep.saving,
        isLoading: false,
      );
      await _calculateAndSaveResult();
    } else {
      state = state.copyWith(
        error: 'Değerlendirme yapılamadı',
        isLoading: false,
      );
    }
  }

  Future<void> _calculateAndSaveResult() async {
    state = state.copyWith(isLoading: true);

    // 1. Doğru cevap sayılarını bul
    int readingCorrect = 0;
    int totalReading = state.currentReading?.questions.length ?? 3;
    if (state.currentReading != null) {
      for (int i = 0; i < state.currentReading!.questions.length; i++) {
        final q = state.currentReading!.questions[i];
        if (state.readingAnswers[i + 1] == q.correctAnswer) {
          readingCorrect++;
        }
      }
    }

    int listeningCorrect = 0;
    int totalListening = state.currentListening?.questions.length ?? 3;
    if (state.currentListening != null) {
      for (int i = 0; i < state.currentListening!.questions.length; i++) {
        final q = state.currentListening!.questions[i];
        if (state.listeningAnswers[i + 1] == q.correctAnswer) {
          listeningCorrect++;
        }
      }
    }

    // 2. Skoru hesapla
    double rScore = totalReading > 0 ? (readingCorrect / totalReading) : 0;
    double lScore = totalListening > 0
        ? (listeningCorrect / totalListening)
        : 0;
    double wScore = state.writingScore / 100.0;
    double sScore = state.speakingScore / 100.0;

    double totalScore = (rScore + lScore + wScore + sScore) / 4.0;

    int levelInt = 1;
    String levelStr = 'A1';

    if (totalScore <= 0.30) {
      levelInt = 1;
      levelStr = 'A1';
    } else if (totalScore <= 0.50) {
      levelInt = 2;
      levelStr = 'A2';
    } else if (totalScore <= 0.65) {
      levelInt = 3;
      levelStr = 'B1';
    } else if (totalScore <= 0.80) {
      levelInt = 4;
      levelStr = 'B2';
    } else {
      levelInt = 5;
      levelStr = 'C1';
    }

    // 3. DB Kayıt (Dummy veriler ve asıl level)
    try {
      for (int l = 1; l <= levelInt; l++) {
        // Her skill için
        // Reading (1)
        await _studentService.submitStudentProgressRL(
          GeneralStudentSubmitRlDto(
            levelType: l,
            skillType: 1,
            statusType: 3,
            correctCount: 3,
            totalCount: 3,
          ),
        );
        // Listening (3)
        await _studentService.submitStudentProgressRL(
          GeneralStudentSubmitRlDto(
            levelType: l,
            skillType: 3,
            statusType: 3,
            correctCount: 3,
            totalCount: 3,
          ),
        );
        // Writing (2)
        await _studentService.submitStudentProgressWS(
          GeneralStudentSubmitWsDto(
            levelType: l,
            skillType: 2,
            statusType: 3,
            aiScores: [90],
            totalCount: 1,
          ),
        );
        // Speaking (4)
        await _studentService.submitStudentProgressWS(
          GeneralStudentSubmitWsDto(
            levelType: l,
            skillType: 4,
            statusType: 3,
            aiScores: [90],
            totalCount: 1,
          ),
        );
      }

      // 4. Enrollments sadece hedeflenen levele
      await _studentService.postUserSkillEnrollment(
        PostUserSkillEnrollmentDto(skillType: 1, levelType: levelInt),
      );
      await _studentService.postUserSkillEnrollment(
        PostUserSkillEnrollmentDto(skillType: 2, levelType: levelInt),
      );
      await _studentService.postUserSkillEnrollment(
        PostUserSkillEnrollmentDto(skillType: 3, levelType: levelInt),
      );
      await _studentService.postUserSkillEnrollment(
        PostUserSkillEnrollmentDto(skillType: 4, levelType: levelInt),
      );

      state = state.copyWith(
        determinedLevel: levelStr,
        currentStep: PlacementStep.result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Sonuçlar kaydedilirken hata oluştu: $e',
        isLoading: false,
      );
    }
  }
}
