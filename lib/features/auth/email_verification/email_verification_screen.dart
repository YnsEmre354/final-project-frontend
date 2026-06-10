import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/register_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/firebase_auth_service.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/student_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_test_screen.dart';

/// Shown immediately after Firebase email-verification is sent during registration.
/// The user must open the email, click the link, then tap "E-postayı Doğruladım".
class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String name;
  final String surname;
  final String username;
  final String nativeLanguage;
  final String gender;

  const EmailVerificationScreen({
    super.key,
    required this.name,
    required this.surname,
    required this.username,
    required this.nativeLanguage,
    required this.gender,
  });

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();
  final StudentService _studentService = StudentService();

  bool _isChecking = false;
  bool _isResending = false;
  String? _errorMessage;

  static const Color _duoBlue = Color(0xFF1CB0F6);

  // ── Resend verification email ───────────────────────────────────────────────

  Future<void> _resendVerification() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    try {
      await _firebaseAuth.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Doğrulama e-postası tekrar gönderildi.'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = 'E-posta gönderilemedi: $e');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ── Check verification and complete registration ────────────────────────────

  Future<void> _checkVerificationAndRegister() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      // Reload Firebase user to get latest emailVerified status
      final isVerified = await _firebaseAuth.isEmailVerified();

      if (!isVerified) {
        setState(() {
          _isChecking = false;
          _errorMessage =
              'E-posta adresiniz henüz doğrulanmamış. Lütfen gelen kutunuzu kontrol edin ve doğrulama bağlantısına tıklayın.';
        });
        return;
      }

      // Get fresh Firebase ID token
      final idToken = await _firebaseAuth.getIdToken(forceRefresh: true);
      
      print('=== DEBUG FIREBASE STATUS ===');
      print('Firebase user exists: ${_firebaseAuth.currentUser != null}');
      print('user.emailVerified after reload: $isVerified');
      print('ID token created: ${idToken != null}');
      
      if (idToken == null) {
        setState(() {
          _isChecking = false;
          _errorMessage = 'Firebase token alınamadı. Lütfen tekrar deneyin.';
        });
        return;
      }

      // Complete backend registration
      final result = await _studentService.completeFirebaseRegister(
        idToken: idToken,
        name: widget.name,
        surname: widget.surname,
        username: widget.username,
        nativeLanguage: widget.nativeLanguage,
        gender: widget.gender,
      );

      if (!mounted) return;

      switch (result) {
        case RegisterEnumResult.success:
          // Load user profile and navigate to placement test
          await ref.read(userProvider.notifier).logUser();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PlacementTestScreen()),
            (route) => false,
          );
          break;

        case RegisterEnumResult.emailTaken:
          setState(() {
            _isChecking = false;
            _errorMessage =
                'Bu e-posta adresi zaten kayıtlı. Lütfen giriş yapmayı deneyin.';
          });
          break;

        case RegisterEnumResult.usernameTaken:
          setState(() {
            _isChecking = false;
            _errorMessage =
                'Bu kullanıcı adı zaten alınmış. Lütfen kayıt ekranına dönün ve farklı bir kullanıcı adı seçin.';
          });
          break;

        default:
          setState(() {
            _isChecking = false;
            _errorMessage = 'Kayıt tamamlanamadı. Lütfen tekrar deneyin.';
          });
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
        _errorMessage = 'Bir hata oluştu: $e';
      });
    }
  }

  // ── Back to login ───────────────────────────────────────────────────────────

  void _backToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'E-posta Doğrulama',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // ── Icon card ─────────────────────────────────────────────────────
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_duoBlue, Color(0xFF1899D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _duoBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Title ─────────────────────────────────────────────────────────
            const Text(
              'Doğrulama E-postası Gönderildi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'E-posta adresinize bir doğrulama bağlantısı gönderdik. '
              'Lütfen gelen kutunuzu kontrol edin ve bağlantıya tıklayın.\n\n'
              'Doğruladıktan sonra aşağıdaki butona basın.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // ── Error message ─────────────────────────────────────────────────
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4B4B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF4B4B).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFFF4B4B),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFF4B4B),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Confirm button ────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _duoBlue.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: _isChecking ? null : _checkVerificationAndRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _duoBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isChecking
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'E-postayı Doğruladım',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Resend button ─────────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _isResending ? null : _resendVerification,
              icon: _isResending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: _duoBlue,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Tekrar Gönder'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _duoBlue,
                side: const BorderSide(color: _duoBlue, width: 1.5),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Back to login link ────────────────────────────────────────────
            TextButton(
              onPressed: _backToLogin,
              child: Text(
                'Giriş ekranına dön',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
