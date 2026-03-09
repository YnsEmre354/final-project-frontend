import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/providers/student_service_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/change_password/change_password_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/change_password/change_password_state.dart';

final changePasswordProvider =
    StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
      final service = ref.read(studentServiceProvider);
      return ChangePasswordNotifier(service);
    });
