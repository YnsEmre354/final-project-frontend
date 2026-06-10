import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/firebase_auth_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/register/register_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/register/register_state.dart';

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) {
    return RegisterNotifier(FirebaseAuthService());
  },
);
