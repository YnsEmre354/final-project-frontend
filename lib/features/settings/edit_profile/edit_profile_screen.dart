import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/change_username_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/delete_user_enum.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/student/auth_storage.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/edit_profile/edit_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _nameSurnameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    final userState = ref.read(userProvider);

    _usernameController = TextEditingController(
      text: userState.logUserDto!.userName,
    );
    _nameSurnameController = TextEditingController(
      text: '${userState.logUserDto!.name} ${userState.logUserDto!.surname}',
    );
    _emailController = TextEditingController(text: userState.logUserDto!.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameSurnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProfileProvider);
    const Color duoBlue = Color(0xFF1CB0F6);
    const Color duoGray = Color(0xFFE5E5E5);
    const Color errorRed = Color(0xFFFF4B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Profili Düzenle",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: editState.isLoading
                ? null
                : () async {
                    final result = await ref
                        .read(editProfileProvider.notifier)
                        .changeUsername(username: _usernameController.text);

                    if (!context.mounted) return;

                    switch (result) {
                      case ChangeUsernameResult.success:
                        _getScaffoldMessage(
                          "Kullanıcı adı başarıyla değiştirildi!",
                        );
                        break;
                      case ChangeUsernameResult.userNotFound:
                        _getScaffoldMessage("Kullanıcı bulunamadı!");
                        break;
                      case ChangeUsernameResult.noChange:
                        _getScaffoldMessage(
                          "Yeni kullanıcı adı eski ile aynı.",
                        );
                        break;
                      case ChangeUsernameResult.usernameTaken:
                        _getScaffoldMessage("Bu kullanıcı adı zaten alınmış.");
                        break;
                      case ChangeUsernameResult.error:
                        _getScaffoldMessage("Bir hata oluştu. Tekrar deneyin.");
                        break;
                    }
                  },
            child: const Text(
              "KAYDET",
              style: TextStyle(color: duoBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PROFİL FOTOĞRAFI BÖLÜMÜ ---
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: duoGray, width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 70, color: duoBlue),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCircleIcon(Icons.camera_alt, duoBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- GİRİŞ ALANLARI ---
            _buildSectionTitle("KİŞİSEL BİLGİLER"),
            _buildCustomTextField(
              controller: _usernameController,
              label: "Kullanıcı Adı",
              icon: Icons.person,
              enabled: true,
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _nameSurnameController,
              label: "Ad Soyad",
              icon: Icons.badge_outlined,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _emailController,
              label: "Email",
              icon: Icons.email_outlined,
              enabled: false,
            ),

            const SizedBox(height: 40),

            _buildSectionTitle("HESAP YÖNETİMİ"),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: duoGray),
              ),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: errorRed),
                title: const Text(
                  "Hesabı Sil",
                  style: TextStyle(
                    color: errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("Bu işlem geri alınamaz."),
                onTap: editState.isLoading
                    ? null
                    : () async {
                        // Onay dialogü
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Hesabı Sil"),
                            content: const Text(
                              "Hesabınızı silmek istediğinizden emin misiniz? "
                              "Bu işlem geri alınamaz.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("İptal"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: errorRed,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Sil"),
                              ),
                            ],
                          ),
                        );

                        if (confirmed != true) return;
                        if (!context.mounted) return;

                        final result = await ref
                            .read(editProfileProvider.notifier)
                            .deleteUser();
                        if (!context.mounted) return;

                        switch (result) {
                          case DeleteUserResult.success:
                            // Token temizle
                            await AuthStorage().deleteToken();
                            if (!context.mounted) return;
                            // Stack tamamen temizlenerek login'e git
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                            break;

                          case DeleteUserResult.alreadyDeleted:
                            _getScaffoldMessage("Hesap zaten silinmiş.");
                            break;

                          case DeleteUserResult.noDeleted:
                            _getScaffoldMessage("Hesap silinemedi.");
                            break;

                          case DeleteUserResult.userNotFound:
                            _getScaffoldMessage("Kullanıcı bulunamadı.");
                            break;

                          case DeleteUserResult.error:
                            _getScaffoldMessage(
                              "Bir hata oluştu. Tekrar deneyin.",
                            );
                            break;
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF1CB0F6) : Colors.grey,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1CB0F6), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _getScaffoldMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
