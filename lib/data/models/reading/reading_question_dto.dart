class ReadingQuestionDto {
  final int id;
  final String text;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  ReadingQuestionDto({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory ReadingQuestionDto.fromJson(Map<String, dynamic> json) {
    return ReadingQuestionDto(
      id: (json['id'] ?? json['Id'] ?? 0) as int,

      text: json['text'] ?? "Soru metni bulunamadı",

      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],

      correctAnswer: json['correctAnswer'] ?? "",
      explanation: json['explanation'] ?? "",
    );
  }
}
