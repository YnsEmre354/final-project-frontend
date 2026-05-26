import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/exam_type.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/ai_service.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/exams/exam_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/exams/exam_state.dart';

final examNotifierProvider =
    StateNotifierProvider.family<
      ExamNotifier,
      ExamState,
      ({String level, ExamType type})
    >((ref, arg) {
      return ExamNotifier(AiService(), arg.level, arg.type, StudentService());
    });
