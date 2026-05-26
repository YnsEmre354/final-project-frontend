class WritingEvaluationDto {
  final String correctedText;
  final String feedback;
  final String detectedLevel;
  final String motivationMessage;
  final int score;

  WritingEvaluationDto({
    required this.correctedText,
    required this.feedback,
    required this.detectedLevel,
    required this.motivationMessage,
    required this.score,
  });

  factory WritingEvaluationDto.fromJson(Map<String, dynamic> json) {
    return WritingEvaluationDto(
      correctedText: json['correctedText'] ?? "",
      feedback: json['feedback'] ?? "",
      detectedLevel: json['detectedLevel'] ?? "",
      motivationMessage: json['motivationMessage'] ?? "",
      score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '0') ?? 0,
    );
  }
}
