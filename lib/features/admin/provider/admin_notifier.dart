import 'package:flutter_turkce_ogrenme_application/data/services/admin_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/admin/provider/admin_state.dart';
import 'package:state_notifier/state_notifier.dart';

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminService _adminService;

  AdminNotifier(this._adminService) : super(AdminState());

  Future<bool> loginAdmin(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _adminService.loginAdmin(email, password);
      if (success) {
        state = state.copyWith(isLoading: false, isLoginSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Admin girişi başarısız. Bilgileri kontrol edin.",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Bir hata oluştu: $e");
      return false;
    }
  }

  Future<void> fetchAllUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await _adminService.getAllUsers();
      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Kullanıcılar getirilirken hata oluştu: $e",
      );
    }
  }

  Future<void> fetchUserProgress(String userId) async {
    state = state.copyWith(isProgressLoading: true, error: null);
    try {
      final progressList = await _adminService.getUserProgress(userId);
      state = state.copyWith(
        isProgressLoading: false,
        selectedUserProgress: progressList,
      );
    } catch (e) {
      state = state.copyWith(
        isProgressLoading: false,
        error: "İlerleme bilgisi getirilirken hata oluştu: $e",
      );
    }
  }

  Future<bool> softDeleteUser(String userId) async {
    try {
      final success = await _adminService.softDeleteUser(userId);
      if (success) {
        await fetchAllUsers();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> activateUser(String userId) async {
    try {
      final success = await _adminService.activeUser(userId);
      if (success) {
        await fetchAllUsers();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
