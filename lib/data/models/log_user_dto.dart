class LogUserDto {
  final String name;
  final String surname;
  final String userName;
  final String email;
  final String nativeLanguage;
  final String? profilePicture;
  final bool isActive;
  final String userId;
  final String? gender;

  LogUserDto({
    required this.name,
    required this.surname,
    required this.userName,
    required this.email,
    required this.nativeLanguage,
    required this.profilePicture,
    required this.isActive,
    required this.userId,
    required this.gender,
  });

  factory LogUserDto.fromJson(Map<String, dynamic> json) {
    return LogUserDto(
      name: json['name'],
      surname: json['surname'],
      userName: json['username'],
      email: json['email'],
      nativeLanguage: json['nativeLanguage'],
      profilePicture: json['profilePicture'],
      isActive: json['isActive'],
      userId: json['userId'],
      gender: json['gender'],
    );
  }
}
