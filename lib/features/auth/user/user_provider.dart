import 'package:flutter_turkce_ogrenme_application/data/providers/student_service_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final service = ref.read(studentServiceProvider);
  return UserNotifier(service);
});
