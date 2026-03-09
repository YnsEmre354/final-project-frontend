import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/user/user_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConsumerScreenState();
}

class _ConsumerScreenState extends ConsumerState<HomeScreen> {
  late String username;
  @override
  /* void initState() {
    super.initState();
    final useState = ref.read(userProvider);
    username = useState.logUserDto!.name + useState.logUserDto!.userName;
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Merhaba,",
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "aaaa",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 50),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
              child: Text(""),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dailyGoalCard(),
          const SizedBox(height: 20),
          _sectionLabel("Öğrenme Yolu"),
          const SizedBox(height: 12),
          _levelSection(
            "A1 — Başlangıç Seviyesi",
            "A1",
            const Color(0xFF2563EB),
            const Color(0xFFEFF6FF),
            const Color(0xFFBFDBFE),
            [
              _TopicData("Tanışma", "👋", completed: true),
              _TopicData("Sayılar", "🔢", completed: true),
              _TopicData("Renkler", "🎨"),
              _TopicData("Aile", "👨‍👩‍👧"),
            ],
            completedCount: 2,
          ),
          const SizedBox(height: 16),
          _levelSection(
            "A2 — Temel Seviye",
            "A2",
            const Color(0xFF0891B2),
            const Color(0xFFECFEFF),
            const Color(0xFFA5F3FC),
            [
              _TopicData("Günlük Rutin", "☀️"),
              _TopicData("Geçmiş Zaman", "⏳"),
              _TopicData("Yol Tarifi", "🗺️", locked: true),
            ],
            completedCount: 0,
          ),
          const SizedBox(height: 16),
          _levelSection(
            "B1 — Orta Seviye",
            "B1",
            const Color(0xFF7C3AED),
            const Color(0xFFF5F3FF),
            const Color(0xFFDDD6FE),
            [
              _TopicData("Gelecek Planları", "🚀", locked: true),
              _TopicData("Duygular", "😊", locked: true),
              _TopicData("İş Hayatı", "💼", locked: true),
            ],
            completedCount: 0,
            sectionLocked: true,
          ),
          const SizedBox(height: 16),
          _levelSection(
            "B2 — İleri Seviye",
            "B2",
            const Color(0xFFEA580C),
            const Color(0xFFFFF7ED),
            const Color(0xFFFED7AA),
            [
              _TopicData("Tartışma", "🗣️", locked: true),
              _TopicData("Edebiyat", "📚", locked: true),
            ],
            completedCount: 0,
            sectionLocked: true,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- Günlük Hedef Kartı ---
  Widget _dailyGoalCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text("🎯", style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Günlük Hedef",
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (i) => Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: i < 2
                              ? Colors.white
                              : Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "2/5 ders tamamlandı",
                  style: TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            "40%",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  // --- Section Label ---
  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  // --- Level Section ---
  Widget _levelSection(
    String title,
    String label,
    Color color,
    Color lightColor,
    Color borderColor,
    List<_TopicData> topics, {
    int completedCount = 0,
    bool sectionLocked = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: sectionLocked ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sectionLocked ? const Color(0xFFE2E8F0) : borderColor,
              width: 1.5,
            ),
            boxShadow: sectionLocked
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: sectionLocked ? const Color(0xFFF1F5F9) : lightColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sectionLocked
                        ? const Color(0xFFE2E8F0)
                        : borderColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: sectionLocked
                      ? const Text("🔒", style: TextStyle(fontSize: 16))
                      : Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: sectionLocked
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (!sectionLocked) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: completedCount / topics.length,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$completedCount/${topics.length}",
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      const Text(
                        "Önceki seviyeleri tamamla",
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Topics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
          children: topics
              .map((t) => _topicCard(t, color, lightColor, borderColor))
              .toList(),
        ),
      ],
    );
  }

  // --- Topic Card ---
  Widget _topicCard(
    _TopicData topic,
    Color color,
    Color lightColor,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: topic.locked ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: topic.locked
              ? const Color(0xFFE2E8F0)
              : topic.completed
              ? borderColor
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: topic.locked
            ? []
            : [
                const BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: topic.locked ? null : () {},
          borderRadius: BorderRadius.circular(18),
          splashColor: color.withOpacity(0.08),
          highlightColor: lightColor,
          child: Opacity(
            opacity: topic.locked ? 0.5 : 1.0,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(topic.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          topic.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: topic.locked
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (topic.completed)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          "✓",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (topic.locked)
                  const Positioned(
                    top: 7,
                    right: 7,
                    child: Text("🔒", style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicData {
  final String title;
  final String emoji;
  final bool completed;
  final bool locked;

  const _TopicData(
    this.title,
    this.emoji, {
    this.completed = false,
    this.locked = false,
  });
}
