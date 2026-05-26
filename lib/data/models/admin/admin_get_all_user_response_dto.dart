class AdminGetAllUserResponseDto {
  final String name;
  final String surname;
  final String username;
  final String email;
  final String nativeLanguage;
  final String createdDate;
  final bool isActive;
  final String gender;
  final String userId;

  AdminGetAllUserResponseDto({
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    required this.nativeLanguage,
    required this.createdDate,
    required this.isActive,
    required this.gender,
    required this.userId,
  });

  factory AdminGetAllUserResponseDto.fromJson(Map<String, dynamic> json) {
    return AdminGetAllUserResponseDto(
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nativeLanguage: json['nativeLanguage'] ?? '',
      createdDate: json['createdDate'] ?? '',
      isActive: json['isActive'] ?? false,
      gender: json['gender'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  static List<AdminGetAllUserResponseDto> adminUserListFromJson(dynamic json) {
    return (json as List)
        .map(
          (e) => AdminGetAllUserResponseDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
