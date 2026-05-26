class SpeakingContentDto {
  final String title;
  final String instructions;
  final String targetLevel;
  final List<String> suggestedVocabulary;
  final List<String> speakingTips;

  SpeakingContentDto({
    required this.title,
    required this.instructions,
    required this.targetLevel,
    required this.suggestedVocabulary,
    required this.speakingTips,
  });

  factory SpeakingContentDto.fromJson(Map<String, dynamic> json) {
    return SpeakingContentDto(
      title: json['title'] ?? "",
      instructions: json['instructions'] ?? "",
      targetLevel: json['targetLevel'] ?? "",
      suggestedVocabulary: (json['suggestedVocabulary'] as List)
          .map((q) => q.toString())
          .toList(),
      speakingTips: (json['speakingTips'] as List)
          .map((q) => q.toString())
          .toList(),
    );
  }
}
