class GeneralStudentSubmitWsDto {
  final int levelType;
  final int skillType;
  final int statusType;
  final List<int> aiScores;
  final int totalCount;

  GeneralStudentSubmitWsDto({
    required this.levelType,
    required this.skillType,
    required this.statusType,
    required this.aiScores,
    required this.totalCount,
  });
}
