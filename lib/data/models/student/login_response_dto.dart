class LoginResponseDto {
  final String token;

  LoginResponseDto({required this.token});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(token: json['token']);
  }
}
