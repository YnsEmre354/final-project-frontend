class GetScoreboardDto {
  final String username;
  final int skillType;
  final int levelType;
  final int point;

  GetScoreboardDto({
    required this.username,
    required this.skillType,
    required this.levelType,
    required this.point,
  });

  factory GetScoreboardDto.fromJson(Map<String, dynamic> json) {
    return GetScoreboardDto(
      username: json['username'] ?? "",
      skillType: json['skillType'] ?? 0,
      levelType: json['levelType'] ?? 0,
      point: json['point'] ?? 0,
    );
  }
}
