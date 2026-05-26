import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/admin/admin_student_progress_response_dto.dart';
import 'package:flutter_turkce_ogrenme_application/features/admin/provider/admin_provider.dart';

class AdminUserProgressScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const AdminUserProgressScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<AdminUserProgressScreen> createState() => _AdminUserProgressScreenState();
}

class _AdminUserProgressScreenState extends ConsumerState<AdminUserProgressScreen> {
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback: ref'in güvenli kullanımı için ilk frame'den sonra çağır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).fetchUserProgress(widget.userId);
    });
  }

  String _getSkillName(int skillType) {
    switch (skillType) {
      case 1:
        return "Okuma (Reading)";
      case 2:
        return "Dinleme (Listening)";
      case 3:
        return "Yazma (Writing)";
      case 4:
        return "Konuşma (Speaking)";
      default:
        return "Yetenek $skillType";
    }
  }

  String _getLevelName(int levelType) {
    switch (levelType) {
      case 1:
        return "A1 Seviye";
      case 2:
        return "A2 Seviye";
      case 3:
        return "B1 Seviye";
      case 4:
        return "B2 Seviye";
      case 5:
        return "C1 Seviye";
      case 6:
        return "C2 Seviye";
      default:
        return "Seviye $levelType";
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color duoBlue = Color(0xFF1CB0F6);
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "${widget.userName} - İlerleme",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: duoBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: adminState.isProgressLoading
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
              : adminState.selectedUserProgress.isEmpty
                  ? const Center(
                      child: Text(
                        "Bu kullanıcı için henüz ilerleme verisi bulunmuyor.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(adminProvider.notifier).fetchUserProgress(widget.userId);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: adminState.selectedUserProgress.length,
                        itemBuilder: (context, index) {
                          final progress = adminState.selectedUserProgress[index];
                          return _buildProgressCard(progress);
                        },
                      ),
                    ),
    );
  }

  Widget _buildProgressCard(AdminStudentProgressResponseDto progress) {
    const Color duoGreen = Color(0xFF58CC02);
    const Color duoOrange = Color(0xFFFF9600);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getSkillName(progress.skillType),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getLevelName(progress.levelType),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn("Doğru", "${progress.correctAnswers}", duoGreen),
                _buildStatColumn("Soru", "${progress.totalQuestions}", Colors.grey.shade700),
                _buildStatColumn("Ortalama", "${progress.averageScore.toStringAsFixed(1)}", duoOrange),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress.progressPercentage / 100.0,
                      backgroundColor: Colors.grey.shade200,
                      color: duoGreen,
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "%${progress.progressPercentage}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Son Güncelleme: ${progress.lastUpdated.split('T').first}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (progress.isPassed)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: duoGreen, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Geçti",
                        style: TextStyle(color: duoGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
