import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/providers/student_service_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/register/register_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/register/register_state.dart';

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) {
    final service = ref.read(studentServiceProvider);
    return RegisterNotifier(service);
  },
);
