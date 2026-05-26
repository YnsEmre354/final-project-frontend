import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/features/admin/presentation/admin_user_progress_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/admin/provider/admin_provider.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/admin/admin_get_all_user_response_dto.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).fetchAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color duoBlue = Color(0xFF1CB0F6);
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Kullanıcılar",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: duoBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminState.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      adminState.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : adminState.users.isEmpty
                  ? const Center(
                      child: Text(
                        "Hiç kullanıcı bulunamadı.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(adminProvider.notifier).fetchAllUsers();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: adminState.users.length,
                        itemBuilder: (context, index) {
                          final user = adminState.users[index];
                          return _buildUserCard(context, user);
                        },
                      ),
                    ),
    );
  }

  Widget _buildUserCard(BuildContext context, AdminGetAllUserResponseDto user) {
    const Color duoGreen = Color(0xFF58CC02);
    const Color duoRed = Color(0xFFFF4B4B);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminUserProgressScreen(
                userId: user.userId,
                userName: '${user.name} ${user.surname}',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 25,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.name} ${user.surname}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.isActive ? duoGreen.withOpacity(0.2) : duoRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.isActive ? "Aktif" : "Pasif",
                      style: TextStyle(
                        color: user.isActive ? duoGreen : duoRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            user.isActive ? "Pasifleştir" : "Aktifleştir",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: user.isActive ? duoRed : duoGreen,
                            ),
                          ),
                          content: Text(
                            user.isActive
                                ? "${user.name} ${user.surname} adlı kullanıcıyı pasifleştirmek istediğinize emin misiniz?"
                                : "${user.name} ${user.surname} adlı kullanıcıyı aktifleştirmek istediğinize emin misiniz?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: user.isActive ? duoRed : duoGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                user.isActive ? "Pasifleştir" : "Aktifleştir",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true || !context.mounted) return;

                      bool success;
                      if (user.isActive) {
                        success = await ref
                            .read(adminProvider.notifier)
                            .softDeleteUser(user.userId);
                      } else {
                        success = await ref
                            .read(adminProvider.notifier)
                            .activateUser(user.userId);
                      }

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? user.isActive
                                    ? "${user.name} pasifleştirildi."
                                    : "${user.name} aktifleştirildi."
                                : "İşlem başarısız. Tekrar deneyin.",
                          ),
                          backgroundColor: success
                              ? (user.isActive ? duoRed : duoGreen)
                              : Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user.isActive ? duoRed : duoGreen,
                      side: BorderSide(
                        color: user.isActive ? duoRed : duoGreen,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      user.isActive ? "Pasifleştir" : "Aktifleştir",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
