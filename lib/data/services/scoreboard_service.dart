import 'package:dio/dio.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/scoreboard/get_scoreboard_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/scoreboard/post_scoreboard_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/api_service.dart';

class ScoreboardService {
  final Dio _dio = ApiService().dio;

  Future<List<GetScoreboardDto>?> getDailyScore() async {
    try {
      final response = await _dio.get('/DailyScore/get-daily-score');
      if (response.statusCode == 200) {
        List<dynamic> rawData = response.data['scoreList'];

        List<GetScoreboardDto> scoreList = rawData
            .map((json) => GetScoreboardDto.fromJson(json))
            .toList();

        return scoreList;
      }

      return [];
    } catch (e) {
      print("Hata oluştu: $e");
      return [];
    }
  }

  Future<bool> postDailyScore(PostScoreboardDto dto) async {
    try {
      await _dio.post(
        '/DailyScore/post-daily-score',
        data: {
          'points': dto.point,
          'skillType': dto.skillType,
          'levelType': dto.levelType,
        },
      );

      return true;
    } catch (e) {
      print("Hata oluştu: $e");
      return false;
    }
  }
}
