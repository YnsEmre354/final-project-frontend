import 'package:dio/dio.dart';

class SpeakingEvaluationRequestDto {
  final String level;
  final String topic;
  final String instructions;
  final String audioFilePath;

  SpeakingEvaluationRequestDto({
    required this.level,
    required this.topic,
    required this.instructions,
    required this.audioFilePath,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'level': level,
      'topic': topic,
      'instructions': instructions,

      'audioFile': await MultipartFile.fromFile(
        audioFilePath,
        filename: 'student_speech.mp3',
      ),
    });
  }
}
