import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/login_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/admin/presentation/admin_login_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/register/register_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/home/home_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_test_screen.dart';
import 'package:flutter_turkce_ogrenme_application/main.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with RouteAware {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordObscure = true;
  int _adminTapCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _resetControllers();
    ref.read(loginProvider.notifier).loginClear();
  }

  @override
  void initState() {
    super.initState();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const Color duoBlue = Color(0xFF1CB0F6);
    const Color duoGray = Color(0xFFE5E5E5);
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Giriş Yap",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _adminTapCount++;
              });
              if (_adminTapCount >= 3) {
                _adminTapCount = 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen(),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.shield_outlined,
                color: Colors.grey.shade300,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (loginState.isLoading) const CircularProgressIndicator(),

            const SizedBox(height: 20),

            if (loginState.error != null)
              Text(
                loginState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),

            /*TextField(
              controller: _emailController,
              obscureText: false,
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
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: duoGray, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: duoBlue, width: 2),
                ),
              ),
            ),*/
            LoginTextField(
              controller: _emailController,
              isObscureText: false,
              hintText: "E-posta",
              isEmail: true,
              duoBlue: duoBlue,
              duoGray: duoGray,
            ),
            const SizedBox(height: 16),
            LoginTextField(
              controller: _passwordController,
              isObscureText: isPasswordObscure,
              hintText: "Şifre",
              isEmail: false,
              onTap: _toggleVisibility,
              duoBlue: duoBlue,
              duoGray: duoGray,
            ),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: duoBlue.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: loginState.isLoading
                    ? null
                    : () async {
                        // bura değişti
                        final result = await ref
                            .read(loginProvider.notifier)
                            .login(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );

                        if (!context.mounted) return;

                        switch (result) {
                          case LoginResult.success:
                            await ref.read(userProvider.notifier).logUser();
                            _resetControllers();
                            if (!context.mounted) return;
                            // Yeni kullanıcı mı kontrol et
                            final enrollments = await StudentService().getUserEnrollment();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => enrollments.isEmpty
                                    ? const PlacementTestScreen()
                                    : const HomeScreen(),
                              ),
                              (route) => false,
                            );
                            break;

                          case LoginResult.accountPassive:
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Hesabınız pasif durumdadır. Lütfen yönetici ile iletişime geçin.",
                                ),
                                backgroundColor: Colors.orange.shade800,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            break;

                          case LoginResult.invalidCredentials:
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "E-posta veya şifre hatalı. Lütfen kontrol edin.",
                                ),
                                backgroundColor: Colors.orange.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            break;

                          case LoginResult.error:
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Bir hata oluştu. Lütfen daha sonra tekrar deneyin.",
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
                child: loginState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "GİRİŞ YAP",
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
                const Text(
                  "Hesabın yok mu?",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _resetControllers();
                    ref.read(loginProvider.notifier).loginClear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text("KAYIT OL", style: TextStyle(color: duoBlue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleVisibility() {
    setState(() {
      isPasswordObscure = !isPasswordObscure;
    });
  }

  void _resetControllers() {
    _emailController.clear();
    _passwordController.clear();
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isObscureText;
  final String hintText;
  final Color duoBlue;
  final Color duoGray;

  /// 1 --> emaiLTextField  0 --> passwordTextField
  final bool isEmail;
  final VoidCallback? onTap;

  const LoginTextField({
    required this.controller,
    required this.isObscureText,
    required this.hintText,
    required this.isEmail,
    this.onTap,
    required this.duoBlue,
    required this.duoGray,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          obscureText: isObscureText,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            suffixIcon: isEmail
                ? null
                : IconButton(
                    onPressed: onTap,
                    icon: Icon(
                      isObscureText
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
            fillColor: const Color(0xFFF7F7F7),
            prefixIcon: Icon(
              isEmail ? Icons.email_outlined : Icons.lock_outline_rounded,
              color: Colors.grey.shade600,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: duoGray, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: duoBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
