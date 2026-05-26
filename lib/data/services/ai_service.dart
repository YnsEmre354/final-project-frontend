import 'package:dio/dio.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/listening/listening_content_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/reading/reading_content_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_content_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_evaluation_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_evaluation_request_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_evaluation_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_evaluation_request_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_task_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/api_service.dart';

class AiService {
  final Dio _dio = ApiService().dio;

  Future<ReadingContentDto?> getReading(String level, int questionId) async {
    try {
      final response = await _dio.get(
        '/Question/reading/generate/$level?id=$questionId',
      );
      return ReadingContentDto.fromJson(response.data);
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }

  Future<ListeningContentDto?> getListening(
    String level,
    int questionId,
  ) async {
    try {
      final response = await _dio.get(
        '/Question/listening/generate/$level?id=$questionId',
      );
      return ListeningContentDto.fromJson(response.data);
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }

  Future<WritingTaskDto?> getWriting(String level, int questionId) async {
    try {
      final response = await _dio.get(
        '/Question/writing/generate/$level?id=$questionId',
      );
      return WritingTaskDto.fromJson(response.data);
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }

  Future<WritingEvaluationDto?> evaluationWriting(
    WritingEvaluationRequestDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/Question/writing/evaluation',
        data: dto.toJson(),
      );
      return WritingEvaluationDto.fromJson(response.data);
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }

  Future<SpeakingContentDto?> getSpeaking(String level, int questionId) async {
    try {
      final response = await _dio.get(
        '/Question/speaking/generate/$level?id=$questionId',
      );
      return SpeakingContentDto.fromJson(response.data);
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }

  Future<SpeakingEvaluationDto?> evaluateSpeaking(
    SpeakingEvaluationRequestDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/Question/speaking/evaluation',
        data: await dto.toFormData(),
      );
      return SpeakingEvaluationDto.fromJson(response.data);
    } catch (e) {
      print("Speaking evaluation hatası: $e");
      return null;
    }
  }
}
