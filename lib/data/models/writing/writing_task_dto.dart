class WritingTaskDto {
  final String title;
  final String instructions;
  final String targetLevel;
  final List<String> suggestedVocabulary;

  WritingTaskDto({
    required this.title,
    required this.instructions,
    required this.targetLevel,
    required this.suggestedVocabulary,
  });

  factory WritingTaskDto.fromJson(Map<String, dynamic> json) {
    return WritingTaskDto(
      title: json['title'] ?? "",
      instructions: json['instructions'] ?? "",
      targetLevel: json['targetLevel'] ?? "",
      suggestedVocabulary: (json['suggestedVocabulary'] as List)
          .map((q) => q.toString())
          .toList(),
    );
  }
}
