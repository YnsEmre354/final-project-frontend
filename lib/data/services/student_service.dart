import 'package:dio/dio.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/change_password_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/change_username_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/delete_user_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/login_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/register_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/login_response_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/log_user_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/api_service.dart';

class StudentService {
  final Dio _dio = ApiService().dio;

  /// düzenlencek

  Future<List<dynamic>?> getStudents() async {
    try {
      final response = await _dio.get('/Student/active-students');
      return response.data;
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }

  Future<(LoginResult, LoginResponseDto?)> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/Student/login-student',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = LoginResponseDto.fromJson(response.data);
        return (LoginResult.success, data);
      }

      return (LoginResult.error, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 404 ||
          e.response?.statusCode == 400) {
        return (LoginResult.invalidCredentials, null);
      }
      print("Dio Hatası: $e");
      return (LoginResult.error, null);
    } catch (e) {
      print("Beklenmedik Hata: $e");
      return (LoginResult.error, null);
    }
  }

  Future<RegisterEnumResult> registerStudent({
    required String name,
    required String surname,
    required String username,
    required String email,
    required String password,
    required String nativeLanguage,
    required String gender,
  }) async {
    try {
      await _dio.post(
        '/Student/register-student',
        data: {
          'name': name,
          'surname': surname,
          'username': username,
          'email': email,
          'password': password,
          'nativeLanguage': nativeLanguage,
          'gender': gender,
        },
      );
      return RegisterEnumResult.success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        var field = e.response?.data['field'];
        if (field == 'Email') return RegisterEnumResult.emailTaken;
        if (field == 'Username') return RegisterEnumResult.usernameTaken;
      }
      return RegisterEnumResult.error;
    }
  }

  Future<LogUserDto?> getLogStudent() async {
    try {
      final response = await _dio.get('/Student/log-student');
      return LogUserDto.fromJson(response.data);
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }

  Future<ChangePasswordResult> changePasswordStudent({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/Student/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      return ChangePasswordResult.success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return ChangePasswordResult.wrongPassword;
      }

      if (e.response?.statusCode == 404) {
        return ChangePasswordResult.userNotFound;
      }

      return ChangePasswordResult.error;
    }
  }

  Future<ChangeUsernameResult> changeUsernameStudent({
    required String username,
  }) async {
    try {
      await _dio.post('/Student/change-username', data: {'username': username});

      return ChangeUsernameResult.success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return ChangeUsernameResult.noChange;
      }

      if (e.response?.statusCode == 404) {
        return ChangeUsernameResult.userNotFound;
      }

      if (e.response?.statusCode == 200) {
        if (e.response?.statusMessage == "username-no-changed") {
          return ChangeUsernameResult.noChange;
        }
      }
      return ChangeUsernameResult.error;
    }
  }

  Future<DeleteUserResult> deleteStudent() async {
    try {
      await _dio.post('/Student/delete-user');
      return DeleteUserResult.success;
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 409:
          return DeleteUserResult.alreadyDeleted;
        case 404:
          return DeleteUserResult.userNotFound;
        case 200:
          return DeleteUserResult.noDeleted;
      }
      return DeleteUserResult.error;
    }
  }
}
