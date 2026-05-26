class WritingEvaluationRequestDto {
  final String level;
  final String userText;
  final String topic;
  final String instructions;

  WritingEvaluationRequestDto({
    required this.level,
    required this.userText,
    required this.topic,
    required this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'userText': userText,
      'topic': topic,
      'instructions': instructions,
    };
  }
}
