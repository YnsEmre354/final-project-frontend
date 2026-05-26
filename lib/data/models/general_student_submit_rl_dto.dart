class GeneralStudentSubmitRlDto {
  final int levelType;
  final int skillType;
  final int statusType;
  final int correctCount;
  final int totalCount;

  GeneralStudentSubmitRlDto({
    required this.levelType,
    required this.skillType,
    required this.statusType,
    required this.correctCount,
    required this.totalCount,
  });
}
