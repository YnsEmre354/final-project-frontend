import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/change_password/change_password_screen.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/log_user_dto.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/common_widgets/settings_tile.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/edit_profile/edit_profile_screen.dart';
import 'package:flutter_turkce_ogrenme_application/main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingsScreen>
    with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    ref.read(userProvider.notifier).clearError();
  }

  static const _duoBlue = Color(0xFF1CB0F6);
  static const _duoGray = Color(0xFFE5E5E5);

  var dailyGoal = 15;
  bool isNotification = false;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil kartı
                _buildProfileCard(userState.logUserDto),
                const SizedBox(height: 24),

                // Öğrenme bölümü
                _buildSection(
                  title: 'Öğrenme',
                  icon: Icons.school_rounded,
                  children: [
                    SettingsTile(
                      icon: Icons.language,
                      title: 'Dil Seviyem',
                      trailing: Icon(Icons.chevron_right_rounded),
                      color1: Colors.blue.shade300,
                      color2: Colors.deepPurple.shade400,
                    ),
                    const SizedBox(height: 8),
                    SettingsTile(
                      icon: Icons.track_changes,
                      title: 'Günlük Hedef',
                      subtitle: 'Günlük Çalışma Dakikan',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _duoBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$dailyGoal dk',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _duoBlue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      color1: Colors.blue.shade300,
                      color2: Colors.blueAccent.shade400,
                      onTap: () => _showDailyGoalSheet(context),
                    ),
                    const SizedBox(height: 8),
                    SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: 'Bildirimler',
                      subtitle: 'Günlük Hatırlatıcı',
                      trailing: Switch(
                        value: isNotification,
                        onChanged: (value) {
                          setState(() => isNotification = value);
                        },
                        activeColor: _duoBlue,
                      ),
                      color1: Colors.orangeAccent,
                      color2: Colors.yellowAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Hesap bölümü
                _buildSection(
                  title: 'Hesap',
                  icon: Icons.person_outline_rounded,
                  children: [
                    SettingsTile(
                      icon: Icons.person,
                      title: 'Profil',
                      subtitle: 'Profilini Düzenle',
                      trailing: Icon(Icons.chevron_right_rounded),
                      color1: Colors.green.shade500,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Güvenlik bölümü
                _buildSection(
                  title: 'Güvenlik',
                  icon: Icons.security_rounded,
                  children: [
                    SettingsTile(
                      icon: Icons.lock_rounded,
                      title: 'Şifre Değiştir',
                      trailing: Icon(Icons.chevron_right_rounded),
                      color1: Colors.orange.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Çıkış Yap butonu
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.red.shade50,
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.red.shade400,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Çıkış Yap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(LogUserDto? dto) {
    if (dto == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_duoBlue, const Color(0xFF1899D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _duoBlue.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${dto.name[0].toUpperCase()}${dto.surname[0].toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dto.name} ${dto.surname}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dto.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showDailyGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _duoGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Günlük hedefini seç',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [10, 15, 20].map((minute) {
                  final isSelected = dailyGoal == minute;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Material(
                        color: isSelected ? _duoBlue : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            setState(() => dailyGoal = minute);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                '$minute dk',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
