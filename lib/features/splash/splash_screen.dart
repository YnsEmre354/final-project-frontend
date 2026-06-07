import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/home/home_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_test_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Biraz bekletmek splash hissini verir
    await Future.delayed(const Duration(seconds: 2));

    final token = await _storage.read(key: 'token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Token varsa, kullanıcı bilgisini çek
      await ref.read(userProvider.notifier).logUser();
      if (!mounted) return;

      // Enrollment kontrolü
      final studentService = StudentService();
      final enrollments = await studentService.getUserEnrollment();
      
      if (!mounted) return;

      if (enrollments.isEmpty) {
        // Enrollment yoksa placement test'e
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PlacementTestScreen()),
        );
      } else {
        // Varsa HomeScreen'e
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // Token yoksa login ekranına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color duoBlue = Color(0xFF1CB0F6);
    return const Scaffold(
      backgroundColor: duoBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.language,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
