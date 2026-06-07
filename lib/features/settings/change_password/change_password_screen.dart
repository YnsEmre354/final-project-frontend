import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/change_password_enum.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/change_password/change_password_provider.dart';
import 'package:flutter_turkce_ogrenme_application/main.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreen();
}

class _ChangePasswordScreen extends ConsumerState<ChangePasswordScreen>
    with RouteAware {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController1 = TextEditingController();
  final TextEditingController newPasswordController2 = TextEditingController();

  bool _isOldPasswordObscure = true;
  bool _isNewPasswordObscure = true;

  bool get isPasswordMatching =>
      newPasswordController1.text == newPasswordController2.text;

  bool get isPasswordValid =>
      oldPasswordController.text.isNotEmpty && isPasswordMatching;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    oldPasswordController.dispose();
    newPasswordController1.dispose();
    newPasswordController2.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    ref.read(changePasswordProvider.notifier).clearError();
  }

  @override
  void initState() {
    super.initState();
    oldPasswordController.addListener(_onChanged);
    newPasswordController1.addListener(_onChanged);
    newPasswordController2.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {});

    if (ref.read(changePasswordProvider).error != null) {
      ref.read(changePasswordProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color duoBlue = Color(0xFF1CB0F6);
    const Color errorRed = Color(0xFFFF4B4B);

    final changePasswordState = ref.watch(changePasswordProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Şifre Değiştir",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey.shade700),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: duoBlue.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [duoBlue, const Color(0xFF1899D6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Şifreni Güncelle",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Güvenliğin için güçlü bir şifre seç",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mevcut ve yeni şifre",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: oldPasswordController,
                      hint: "Eski Şifre",
                      isObscure: _isOldPasswordObscure,
                      icon: Icons.vpn_key_outlined,
                      toggleVisibility: () => setState(
                        () => _isOldPasswordObscure = !_isOldPasswordObscure,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: newPasswordController1,
                      hint: "Yeni Şifre",
                      isObscure: _isNewPasswordObscure,
                      icon: Icons.lock_outline,
                      toggleVisibility: () => setState(
                        () => _isNewPasswordObscure = !_isNewPasswordObscure,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: newPasswordController2,
                      hint: "Yeni Şifre (Tekrar)",
                      isObscure: _isNewPasswordObscure,
                      icon: Icons.lock_reset_outlined,
                      // Eşleşme kontrolüne göre border rengini değiştirme
                      errorState:
                          newPasswordController2.text.isNotEmpty &&
                          !isPasswordMatching,
                    ),

                    if (newPasswordController2.text.isNotEmpty &&
                        !isPasswordMatching)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: errorRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Şifreler birbiriyle eşleşmiyor",
                              style: TextStyle(
                                color: errorRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (changePasswordState.error != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: errorRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: errorRed.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: errorRed,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                changePasswordState.error!,
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

                    const SizedBox(height: 40),

                    // 3D Stil Buton
                    _buildDuoButton(
                      context: context,
                      isLoading: changePasswordState.isLoading,
                      isEnabled: isPasswordValid,
                      onPressed: () async {
                        final result = await ref
                            .read(changePasswordProvider.notifier)
                            .changePassword(
                              oldPassword: oldPasswordController.text,
                              newPassword: newPasswordController1.text,
                            );
                        if (result == ChangePasswordResult.success) {
                          if (!context.mounted) return;
                          _showSuccessMessage(context);
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Yardımcı Metot: Modern TextField Tasarımı
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    required IconData icon,
    VoidCallback? toggleVisibility,
    bool errorState = false,
  }) {
    const errorRed = Color(0xFFFF4B4B);
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        prefixIcon: Icon(
          icon,
          color: errorState ? errorRed : const Color(0xFF1CB0F6),
        ),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                  isObscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: errorState ? errorRed : const Color(0xFFE5E5E5),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: errorState ? errorRed : const Color(0xFF1CB0F6),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDuoButton({
    required BuildContext context,
    required bool isLoading,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled && !isLoading ? onPressed : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: isEnabled ? const Color(0xFF1CB0F6) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (isEnabled)
                BoxShadow(
                  color: const Color(0xFF1899D6).withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "ŞİFREYİ GÜNCELLE",
                    style: TextStyle(
                      color: isEnabled ? Colors.white : Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Şifreniz başarıyla güncellendi!"),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
