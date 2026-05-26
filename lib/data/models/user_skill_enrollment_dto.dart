class UserSkillEnrollmentDto {
  final int skillType;
  final int levelType;
  final bool isLocked;
  final bool isAttempted;

  UserSkillEnrollmentDto({
    required this.skillType,
    required this.levelType,
    required this.isLocked,
    required this.isAttempted,
  });

  factory UserSkillEnrollmentDto.fromJson(Map<String, dynamic> json) {
    return UserSkillEnrollmentDto(
      skillType: json['skillType'] ?? 0,
      levelType: json['levelType'] ?? 0,
      isLocked: json['isLocked'] ?? true,
      isAttempted: json['isAttempted'] ?? false,
    );
  }
}
