import 'package:flutter_turkce_ogrenme_application/data/enum/exam_type.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/ai_service.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/scoreboard_service.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_evaluation_request_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_evaluation_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_evaluation_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_evaluation_request_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/general_student_submit_rl_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/general_student_submit_ws_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/post_user_skill_enrollment_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/scoreboard/post_scoreboard_dto.dart';
import 'package:flutter_turkce_ogrenme_application/features/exams/exam_state.dart';
import 'package:state_notifier/state_notifier.dart';

class ExamNotifier extends StateNotifier<ExamState> {
  final AiService _aiService;
  final StudentService _studentService;
  final ScoreboardService _scoreboardService = ScoreboardService();
  final String level;
  final ExamType type;

  ExamNotifier(this._aiService, this.level, this.type, this._studentService)
    : super(ExamState(currentIndex: 1)) {
    fetchQuestion(1);
  }

  Future<void> fetchQuestion(int questionId) async {
    final cached = state.visitedQuestions[questionId];
    if (cached != null) {
      state = state.copyWith(
        questions: [cached],
        currentIndex: questionId,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final question = await switch (type) {
      ExamType.reading => _aiService.getReading(level, questionId),
      ExamType.listening => _aiService.getListening(level, questionId),
      ExamType.writing => _aiService.getWriting(level, questionId),
      ExamType.speaking => _aiService.getSpeaking(level, questionId),
    };

    if (question != null) {
      final updated = Map<int, dynamic>.from(state.visitedQuestions);
      updated[questionId] = question;

      state = state.copyWith(
        isLoading: false,
        questions: [question],
        currentIndex: questionId,
        visitedQuestions: updated,
      );
    } else {
      state = state.copyWith(isLoading: false, error: 'Soru getirilemedi.');
    }
  }

  void nextQuestion() => fetchQuestion(state.currentIndex + 1);

  void previousQuestion() {
    if (state.currentIndex <= 1) return;
    fetchQuestion(state.currentIndex - 1);
  }

  bool get canGoBack => state.currentIndex > 1;

  // ── Helpers ────────────────────────────────────────────────────────────────
  int _levelType() => switch (level) {
    'A1' => 1,
    'A2' => 2,
    'B1' => 3,
    'B2' => 4,
    'C1' => 5,
    'C2' => 6,
    _ => 0,
  };

  int _skillType() => switch (type) {
    ExamType.reading => 1,
    ExamType.writing => 2,
    ExamType.listening => 3,
    ExamType.speaking => 4,
  };

  // ── Submit: Reading / Listening (çoktan seçmeli) ──────────────────────────
  Future<void> submitAnswer(String studentAnswer, String correctAnswer) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final updatedAnswers = Map<int, String>.from(state.givenAnswers);
    updatedAnswers[state.currentIndex] = studentAnswer;
    state = state.copyWith(isLoading: false, givenAnswers: updatedAnswers);
  }

  // ── Submit: Writing ────────────────────────────────────────────────────────
  Future<void> submitWritingAnswer(
    String userText,
    String topic,
    String instructions,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final dto = WritingEvaluationRequestDto(
      level: level,
      userText: userText,
      topic: topic,
      instructions: instructions,
    );

    final evaluation = await _aiService.evaluationWriting(dto);

    if (evaluation != null) {
      final updatedAnswers = Map<int, String>.from(state.givenAnswers);
      updatedAnswers[state.currentIndex] = userText;

      final updatedEvaluations = Map<int, WritingEvaluationDto>.from(
        state.writingEvaluations,
      );
      updatedEvaluations[state.currentIndex] = evaluation;

      state = state.copyWith(
        isLoading: false,
        givenAnswers: updatedAnswers,
        writingEvaluations: updatedEvaluations,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Değerlendirme yapılırken bir hata oluştu.',
      );
    }
  }

  // ── Submit: Speaking ───────────────────────────────────────────────────────
  Future<void> submitSpeakingAnswer(
    String audioFilePath,
    String topic,
    String instructions,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final dto = SpeakingEvaluationRequestDto(
      level: level,
      topic: topic,
      instructions: instructions,
      audioFilePath: audioFilePath,
    );

    final result = await _aiService.evaluateSpeaking(dto);

    if (result != null) {
      final updatedAnswers = Map<int, String>.from(state.givenAnswers);
      updatedAnswers[state.currentIndex] = 'recorded';

      final updatedEvaluations = Map<int, SpeakingEvaluationDto>.from(
        state.speakingEvaluations,
      );
      updatedEvaluations[state.currentIndex] = result;

      state = state.copyWith(
        isLoading: false,
        givenAnswers: updatedAnswers,
        speakingEvaluations: updatedEvaluations,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Ses değerlendirilirken bir hata oluştu.',
      );
    }
  }

  // ── Finish Exam ────────────────────────────────────────────────────────────
  Future<bool> finishExam() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final lv = _levelType();
    final sk = _skillType();
    int rlExamCount = 5;
    int wsExamCount = 2;

    try {
      if (type == ExamType.reading || type == ExamType.listening) {
        int correctCount = 0;
        for (int i = 1; i <= rlExamCount; i++) {
          final answer = state.givenAnswers[i];
          final questionData = state.visitedQuestions[i];
          if (answer != null && questionData != null) {
            String correctAns = "";
            try {
              correctAns = questionData.questions[0].correctAnswer as String;
            } catch (e) {
              print("finishExam correctAns extract error: $e");
            }
            if (correctAns.isNotEmpty && answer[0] == correctAns[0]) {
              correctCount++;
            }
          }
        }

        final dto = GeneralStudentSubmitRlDto(
          levelType: lv,
          skillType: sk,
          statusType: 1, // Status types: completed = 1
          correctCount: correctCount,
          totalCount: rlExamCount,
        );

        final isSuccess = await _studentService.submitStudentProgressRL(dto);
        if (isSuccess) {
          await _studentService.postUserSkillEnrollment(
            PostUserSkillEnrollmentDto(skillType: sk, levelType: lv),
          );
          final int rlScore = rlExamCount > 0
              ? (correctCount / rlExamCount * 1000).round()
              : 0;
          await _scoreboardService.postDailyScore(
            PostScoreboardDto(point: rlScore, skillType: sk, levelType: lv),
          );
        }
        state = state.copyWith(isLoading: false, isExamFinished: isSuccess);
        return isSuccess;
      } else {
        List<int> aiScores = [];
        for (int i = 1; i <= wsExamCount; i++) {
          if (type == ExamType.writing) {
            final eval = state.writingEvaluations[i];
            aiScores.add(eval?.score ?? 0);
          } else {
            final eval = state.speakingEvaluations[i];
            aiScores.add(eval?.score ?? 0);
          }
        }

        final dto = GeneralStudentSubmitWsDto(
          levelType: lv,
          skillType: sk,
          statusType: 1, // completed = 1
          aiScores: aiScores,
          totalCount: wsExamCount,
        );

        final isSuccess = await _studentService.submitStudentProgressWS(dto);
        if (isSuccess) {
          await _studentService.postUserSkillEnrollment(
            PostUserSkillEnrollmentDto(skillType: sk, levelType: lv),
          );
          final int avgScore = aiScores.isEmpty
              ? 0
              : (aiScores.reduce((a, b) => a + b) / aiScores.length * 10).round();
          await _scoreboardService.postDailyScore(
            PostScoreboardDto(point: avgScore, skillType: sk, levelType: lv),
          );
        }
        state = state.copyWith(isLoading: false, isExamFinished: isSuccess);
        return isSuccess;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll("Exception: ", ""),
      );
      return false;
    }
  }
}
