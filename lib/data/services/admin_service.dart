import 'package:dio/dio.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/admin/admin_get_all_user_response_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/admin/admin_student_progress_response_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/api_service.dart';

class AdminService {
  final Dio _dio = ApiService().dio;

  Future<bool> loginAdmin(String email, String password) async {
    try {
      final response = await _dio.post(
        "/Admin/login-admin",
        data: {"email": email, "password": password},
      );

      // Başarılı giriş durumunda true dönüyoruz
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Login Hatası: $e");
      return false;
    }
  }

  /// 2. Tüm Kullanıcıları Getirme
  Future<List<AdminGetAllUserResponseDto>> getAllUsers() async {
    try {
      final response = await _dio.get("/Admin/get-all-users");

      if (response.statusCode == 200) {
        return AdminGetAllUserResponseDto.adminUserListFromJson(response.data);
      }
      return [];
    } catch (e) {
      print("Kullanıcı listesi çekilirken hata: $e");
      return [];
    }
  }

  /// 3. Belirli Bir Kullanıcının İlerleme Detaylarını Getirme
  Future<List<AdminStudentProgressResponseDto>> getUserProgress(
    String userId,
  ) async {
    try {
      final response = await _dio.get("/Admin/get-users-progress/$userId");

      if (response.statusCode == 200) {
        return AdminStudentProgressResponseDto.adminStudentProgressListFromJson(
          response.data,
        );
      }
      return [];
    } catch (e) {
      print("İlerleme detayları çekilirken hata: $e");
      return [];
    }
  }

  Future<bool> softDeleteUser(String userId) async {
    try {
      final response = await _dio.post("/Admin/soft-delete-user", data: userId);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Login Hatası: $e");
      return false;
    }
  }

  Future<bool> activeUser(String userId) async {
    try {
      final response = await _dio.post("/Admin/active-user", data: userId);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Login Hatası: $e");
      return false;
    }
  }
}
