import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/register_enum.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/email_verification/email_verification_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/register/register_provider.dart';
import 'package:flutter_turkce_ogrenme_application/main.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with RouteAware {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedValue;
  String? selectedGender;
  bool _isPasswordObscure = true;
  String _password = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  void _onPasswordChanged() {
    setState(() {
      _password = passwordController.text;
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    nameController.dispose();
    surnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.removeListener(_onPasswordChanged);
    passwordController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    ref.read(registerProvider.notifier).registerClear();
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    const Color duoBlue = Color(0xFF1CB0F6);
    const Color duoGray = Color(0xFFE5E5E5);
    const Color errorRed = Color(0xFFFF4B4B);
    final registerState = ref.watch(registerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Kayıt Ol",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: duoBlue.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [duoBlue, const Color(0xFF1899D6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Hesap Oluştur",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Türkçe öğrenmeye başlamak için kayıt ol",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (registerState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: errorRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: errorRed.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 22,
                        color: errorRed,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          registerState.error!,
                          style: TextStyle(
                            color: errorRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bilgilerinizi girin",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "İsim",
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.grey.shade600,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoGray,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: surnameController,
                      decoration: InputDecoration(
                        hintText: "Soyad",
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.grey.shade600,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoGray,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: "Kullanıcı Adı",
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: Colors.grey.shade600,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoGray,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "E-posta",
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey.shade600,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoGray,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: _isPasswordObscure,
                      decoration: InputDecoration(
                        hintText: "Şifre",
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.grey.shade600,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscure
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordObscure = !_isPasswordObscure;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoGray,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Şifre şartları
                    if (_password.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildPasswordRequirements(duoBlue),
                    ],

                    DropdownButtonFormField<String>(
                      initialValue: selectedValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        prefixIcon: Icon(
                          Icons.language_rounded,
                          color: Colors.grey.shade600,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoGray,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoBlue,
                            width: 2,
                          ),
                        ),
                        labelText: "Anadil / Uyruk",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'eng',
                          child: Text("İngilizce"),
                        ),
                        DropdownMenuItem(value: 'ger', child: Text("Almanca")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedGender,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        prefixIcon: Icon(
                          Icons.language_rounded,
                          color: Colors.grey.shade600,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoGray,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: duoBlue,
                            width: 2,
                          ),
                        ),
                        labelText: "Cinsiyet",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text("Erkek")),
                        DropdownMenuItem(value: 'female', child: Text("Kadın")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: duoBlue.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  onPressed: registerState.isLoading
                      ? null
                      : () async {
                          // Şifre şartı kontrolü
                          final pw = passwordController.text;
                          final hasMinLength = pw.length >= 8;
                          final hasLetter = pw.contains(RegExp(r'[a-zA-Z]'));
                          final hasDigit = pw.contains(RegExp(r'[0-9]'));
                          if (!hasMinLength || !hasLetter || !hasDigit) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Şifre en az 8 karakter, 1 harf ve 1 rakam içermelidir.",
                                ),
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }
                          if (selectedValue == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Lütfen uyruğunuzu (dil) seçiniz.",
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }
                          if (selectedGender == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Lütfen cinsiyetinizi seçiniz.",
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }
                          final result = await ref
                              .read(registerProvider.notifier)
                              .register(
                                name: nameController.text,
                                surname: surnameController.text,
                                username: usernameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                nativeLanguage: selectedValue!,
                                gender: selectedGender!,
                              );
                          if (!context.mounted) return;

                          switch (result) {
                            case RegisterEnumResult.emailVerificationSent:
                              // Navigate to email verification screen.
                              // The pendingUserData in state carries form fields.
                              final pending = ref
                                  .read(registerProvider)
                                  .pendingUserData;
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EmailVerificationScreen(
                                    name: pending?['name'] ?? '',
                                    surname: pending?['surname'] ?? '',
                                    username: pending?['username'] ?? '',
                                    nativeLanguage:
                                        pending?['nativeLanguage'] ?? '',
                                    gender: pending?['gender'] ?? '',
                                  ),
                                ),
                                (route) => route.isFirst,
                              );
                              break;

                            case RegisterEnumResult.success:
                              // Legacy path (old backend register) — show success & go to login
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Kayıt başarılı! Lütfen giriş yapın.',
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(context);
                              break;

                            case RegisterEnumResult.emailTaken:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Bu e-posta adresi sistemde zaten kayıtlı. Hesabınız pasif olabilir. Giriş yapmayı deneyin veya yönetici ile iletişime geçin.",
                                  ),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              break;

                            case RegisterEnumResult.usernameTaken:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Bu Kullanıcı Adı Zaten Kayıtlı!",
                                  ),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              break;

                            case RegisterEnumResult.error:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.",
                                  ),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              break;
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: duoBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: registerState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "KAYIT OL",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Zaten hesabın var mı?",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(registerProvider.notifier).registerClear();
                    },
                    child: Text(
                      "Giriş yap",
                      style: TextStyle(
                        color: duoBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements(Color duoBlue) {
    final hasMinLength = _password.length >= 8;
    final hasLetter = _password.contains(RegExp(r'[a-zA-Z]'));
    final hasDigit = _password.contains(RegExp(r'[0-9]'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequirementRow(hasMinLength, "En az 8 karakter"),
          const SizedBox(height: 4),
          _buildRequirementRow(hasLetter, "En az 1 harf"),
          const SizedBox(height: 4),
          _buildRequirementRow(hasDigit, "En az 1 rakam"),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(bool isMet, String label) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 16,
          color: isMet ? const Color(0xFF58CC02) : const Color(0xFFCBD5E1),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isMet ? const Color(0xFF58CC02) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
