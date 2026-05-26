import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/auth_storage.dart';

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});
