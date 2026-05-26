import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/admin_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/admin/provider/admin_notifier.dart';
import 'package:flutter_turkce_ogrenme_application/features/admin/provider/admin_state.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final adminService = ref.read(adminServiceProvider);
  return AdminNotifier(adminService);
});
