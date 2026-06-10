import 'package:dio/dio.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/change_password_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/change_username_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/delete_user_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/login_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/register_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/general_student_submit_rl_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/general_student_submit_ws_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/login_response_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/log_user_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/post_user_skill_enrollment_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/unlock_next_level_enrollment_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/user_skill_enrollment_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/api_service.dart';

class StudentService {
  final Dio _dio = ApiService().dio;

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
      if (e.response?.statusCode == 403) {
        return (LoginResult.accountPassive, null);
      }
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

  // ── Firebase: Login ────────────────────────────────────────────────────────

  /// Exchanges a Firebase ID token for the project's own JWT token.
  /// Called after Firebase sign-in succeeds and emailVerified is true.
  Future<(LoginResult, LoginResponseDto?)> firebaseLogin(String idToken) async {
    try {
      final response = await _dio.post(
        '/Student/firebase-login',
        data: {'idToken': idToken},
      );
      if (response.statusCode == 200) {
        final data = LoginResponseDto.fromJson(response.data);
        return (LoginResult.success, data);
      }
      return (LoginResult.error, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return (LoginResult.accountPassive, null);
      }
      if (e.response?.statusCode == 401) {
        return (LoginResult.emailNotVerified, null);
      }
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        return (LoginResult.invalidCredentials, null);
      }
      return (LoginResult.error, null);
    } catch (e) {
      return (LoginResult.error, null);
    }
  }

  // ── Firebase: Complete Registration ────────────────────────────────────────

  /// Finalises backend student registration after Firebase email is verified.
  /// Sends the Firebase ID token + profile data to create the DB record.
  Future<RegisterEnumResult> completeFirebaseRegister({
    required String idToken,
    required String name,
    required String surname,
    required String username,
    required String nativeLanguage,
    required String gender,
  }) async {
    try {
      print('Endpoint URL: ${_dio.options.baseUrl}/Student/complete-firebase-register');
      final response = await _dio.post(
        '/Student/complete-firebase-register',
        data: {
          'idToken': idToken,
          'name': name,
          'surname': surname,
          'username': username,
          'nativeLanguage': nativeLanguage,
          'gender': gender,
        },
      );
      print('Dio status code: ${response.statusCode}');
      print('Dio response body: ${response.data}');
      return RegisterEnumResult.success;
    } on DioException catch (e) {
      print('Dio error status: ${e.response?.statusCode}');
      print('Dio error response body: ${e.response?.data}');
      if (e.response?.statusCode == 409) {
        final field = e.response?.data['field'];
        if (field == 'Email') return RegisterEnumResult.emailTaken;
        if (field == 'Username') return RegisterEnumResult.usernameTaken;
      }
      if (e.response?.statusCode == 400) {
        return RegisterEnumResult.error;
      }
      return RegisterEnumResult.error;
    } catch (e) {
      print('Unexpected error in completeFirebaseRegister: $e');
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
        // 409 = kullanıcı adı zaten alınmış
        return ChangeUsernameResult.usernameTaken;
      }
      if (e.response?.statusCode == 400) {
        // 400 = aynı kullanıcı adı gönderildi (değişiklik yok)
        return ChangeUsernameResult.noChange;
      }
      if (e.response?.statusCode == 404) {
        return ChangeUsernameResult.userNotFound;
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




  Future<bool> submitStudentProgressRL(GeneralStudentSubmitRlDto dto) async {
    try {
      await _dio.post(
        '/Student/submitStudentProgressRL',
        data: {
          'levelType': dto.levelType,
          'skillType': dto.skillType,
          'statusType': dto.statusType,
          'correctCount': dto.correctCount,
          'totalCount': dto.totalCount,
        },
      );

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Sunucuya ulaşılamıyor (Zaman Aşımı).");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("İnternet bağlantınız kopmuş olabilir.");
      }
      throw Exception("Ağ Hatası: Lütfen bağlantınızı kontrol edin.");
    } catch (e) {
      throw Exception("Beklenmeyen bir hata oluştu: $e");
    }
  }

  Future<bool> submitStudentProgressWS(GeneralStudentSubmitWsDto dto) async {
    try {
      await _dio.post(
        '/Student/submitStudentProgressWS',
        data: {
          'levelType': dto.levelType,
          'skillType': dto.skillType,
          'statusType': dto.statusType,
          'aiScores': dto.aiScores,
          'totalCount': dto.totalCount,
        },
      );

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Sunucuya ulaşılamıyor (Zaman Aşımı).");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("İnternet bağlantınız kopmuş olabilir.");
      }
      throw Exception("Ağ Hatası: Lütfen bağlantınızı kontrol edin.");
    } catch (e) {
      throw Exception("Beklenmeyen bir hata oluştu: $e");
    }
  }

  Future<Map<String, dynamic>?> getLevelPercentages(int levelType) async {
    try {
      final response = await _dio.get(
        '/Student/getProgressPercentage/$levelType',
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("Yüzdeler çekilirken hata oluştu: $e");
      return null;
    }
  }

  Future<List<UserSkillEnrollmentDto>> getUserEnrollment() async {
    try {
      final response = await _dio.get('/Student/getUserSkillEntrollment');

      if (response.statusCode == 200) {
        List<dynamic> rawData = response.data['enrollments'];

        List<UserSkillEnrollmentDto> enrollments = rawData
            .map((json) => UserSkillEnrollmentDto.fromJson(json))
            .toList();

        return enrollments;
      }

      return [];
    } catch (e) {
      print("İlerleme çekilirken hata oluştu: $e");
      return [];
    }
  }

  Future<bool> postUserSkillEnrollment(PostUserSkillEnrollmentDto dto) async {
    try {
      await _dio.post(
        '/Student/post-user-skill-enrollment',
        data: {'skillType': dto.skillType, 'levelType': dto.levelType},
      );

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Sunucuya ulaşılamıyor (Zaman Aşımı).");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("İnternet bağlantınız kopmuş olabilir.");
      }
      throw Exception("Ağ Hatası: Lütfen bağlantınızı kontrol edin.");
    } catch (e) {
      throw Exception("İlerleme gönderilirken hata oluştu: $e");
    }
  }

  Future<bool> unlockNextLevelEnrollment(
    UnlockNextLevelEnrollmentDto dto,
  ) async {
    try {
      await _dio.post(
        '/Student/unlock-next-level',
        data: {
          'skillType': dto.skillType,
          'currentLevel': dto.currentLevel,
          'nextLevel': dto.nextLevel,
        },
      );

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Sunucuya ulaşılamıyor (Zaman Aşımı).");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("İnternet bağlantınız kopmuş olabilir.");
      }
      throw Exception("Ağ Hatası: Lütfen bağlantınızı kontrol edin.");
    } catch (e) {
      throw Exception("Sıradaki level kilidi açılırken hata oluştu: $e");
    }
  }
}
