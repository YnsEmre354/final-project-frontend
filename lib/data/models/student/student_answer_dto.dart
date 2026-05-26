class StudentAnswerDto {
  final int studentId;
  final int levelType;
  final String? studentAnswer;
  final String? correctAnswer;

  StudentAnswerDto({
    required this.studentId,
    required this.levelType,
    this.studentAnswer,
    this.correctAnswer,
  });
}
