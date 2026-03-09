import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/providers/auth_storage_provider.dart';
import 'package:flutter_turkce_ogrenme_application/data/providers/student_service_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_state.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final service = ref.read(studentServiceProvider);
  final authStorage = ref.read(authStorageProvider);
  return LoginNotifier(service, authStorage);
});
