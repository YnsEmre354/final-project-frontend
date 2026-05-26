class AdminStudentProgressResponseDto {
  final int skillId;
  final int skillType;
  final int levelType;
  final int correctAnswers;
  final int totalQuestions;
  final double averageScore;
  final bool isPassed;
  final int progressPercentage;
  final String lastUpdated;

  AdminStudentProgressResponseDto({
    required this.skillId,
    required this.skillType,
    required this.levelType,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.averageScore,
    required this.isPassed,
    required this.progressPercentage,
    required this.lastUpdated,
  });

  factory AdminStudentProgressResponseDto.fromJson(Map<String, dynamic> json) {
    return AdminStudentProgressResponseDto(
      skillId: (json['skillId'] as num?)?.toInt() ?? 0,
      skillType: (json['skillType'] as num?)?.toInt() ?? 0,
      levelType: (json['levelType'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      isPassed: json['isPassed'] as bool? ?? false,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated']?.toString() ?? '',
    );
  }

  static List<AdminStudentProgressResponseDto> adminStudentProgressListFromJson(
    dynamic json,
  ) {
    return (json as List)
        .map(
          (e) => AdminStudentProgressResponseDto.fromJson(
            // 'as Map<String, dynamic>' yerine from() kullanıyoruz.
            // Dio bazen Map<dynamic, dynamic> döner, direkt cast TypeError atar.
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}
