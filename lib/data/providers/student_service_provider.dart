import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService();
});
