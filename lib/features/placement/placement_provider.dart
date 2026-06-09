import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/ai_service.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_state.dart';

final placementProvider =
    StateNotifierProvider.autoDispose<PlacementNotifier, PlacementState>((ref) {
      final aiService = AiService();
      final studentService = StudentService();
      return PlacementNotifier(aiService, studentService);
    });
