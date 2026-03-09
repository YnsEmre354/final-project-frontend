import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/providers/student_service_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/edit_profile/edit_profile_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/edit_profile/edit_profile_state.dart';

final editProfileProvider =
    StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
      final service = ref.read(studentServiceProvider);
      return EditProfileNotifier(service);
    });
