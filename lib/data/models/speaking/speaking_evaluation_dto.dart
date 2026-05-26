class SpeakingEvaluationDto {
  final String correctedText;
  final String feedback;
  final String detectedLevel;
  final String motivationMessage;
  final int score;

  SpeakingEvaluationDto({
    required this.correctedText,
    required this.feedback,
    required this.detectedLevel,
    required this.motivationMessage,
    required this.score,
  });

  factory SpeakingEvaluationDto.fromJson(Map<String, dynamic> json) {
    return SpeakingEvaluationDto(
      correctedText: json['correctedText'] ?? "",
      feedback: json['feedback'] ?? "",
      detectedLevel: json['detectedLevel'] ?? "",
      motivationMessage: json['motivationMessage'] ?? "",
      score: json['score'] is int
          ? json['score']
          : int.tryParse(json['score']?.toString() ?? '0') ?? 0,
    );
  }
}
