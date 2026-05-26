import 'package:flutter_turkce_ogrenme_application/data/models/listening/listening_question_dto.dart';

class ListeningContentDto {
  final String title;
  final String paragraph;
  final List<ListeningQuestionDto> questions;

  ListeningContentDto({
    required this.title,
    required this.paragraph,
    required this.questions,
  });

  factory ListeningContentDto.fromJson(Map<String, dynamic> json) {
    return ListeningContentDto(
      title: json['title'] ?? "",
      paragraph: json['paragraph'] ?? "",
      questions: (json['questions'] as List)
          .map((q) => ListeningQuestionDto.fromJson(q))
          .toList(),
    );
  }
}
