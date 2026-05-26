import 'package:flutter_turkce_ogrenme_application/data/models/reading/reading_question_dto.dart';

class ReadingContentDto {
  final String title;
  final String paragraph;
  final List<ReadingQuestionDto> questions;

  ReadingContentDto({
    required this.title,
    required this.paragraph,
    required this.questions,
  });

  factory ReadingContentDto.fromJson(Map<String, dynamic> json) {
    return ReadingContentDto(
      title: json['title'] ?? "",
      paragraph: json['paragraph'] ?? "",
      questions: (json['questions'] as List)
          .map((q) => ReadingQuestionDto.fromJson(q))
          .toList(),
    );
  }
}
