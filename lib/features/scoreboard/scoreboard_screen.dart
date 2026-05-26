import 'package:flutter/material.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/scoreboard/get_scoreboard_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/services/scoreboard_service.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  List<GetScoreboardDto> _scoreboardData = [];
  bool _isLoadingScoreboard = true;
  final ScoreboardService _scoreboardService = ScoreboardService();

  static const Map<int, String> _levelNames = {
    1: 'A1',
    2: 'A2',
    3: 'B1',
    4: 'B2',
    5: 'C1',
    6: 'C2',
  };

  static const List<_SkillMeta> _skillMetas = [
    _SkillMeta(1, 'Reading', '📚', Color(0xFF2563EB), Color(0xFFEFF6FF)),
    _SkillMeta(2, 'Writing', '✍️', Color(0xFF7C3AED), Color(0xFFF5F3FF)),
    _SkillMeta(3, 'Listening', '🎧', Color(0xFF0891B2), Color(0xFFECFEFF)),
    _SkillMeta(4, 'Speaking', '🗣️', Color(0xFF059669), Color(0xFFECFDF5)),
  ];

  @override
  void initState() {
    super.initState();
    _fetchScoreboard();
  }

  Future<void> _fetchScoreboard() async {
    final data = await _scoreboardService.getDailyScore();
    if (mounted) {
      setState(() {
        _scoreboardData = data ?? [];
        _isLoadingScoreboard = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Günlük Skor Tablosu",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingScoreboard) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_scoreboardData.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'Henüz skor kaydı yok.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
          )
        else
          ..._skillMetas.asMap().entries.map((entry) {
            final idx = entry.key;
            final meta = entry.value;
            final items = _scoreboardData
                .where((s) => s.skillType == meta.skillType)
                .toList()
              ..sort((a, b) {
                if (b.levelType != a.levelType) return b.levelType.compareTo(a.levelType);
                return b.point.compareTo(a.point);
              });

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 350 + idx * 80),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _skillScoreboardCard(meta, items),
              ),
            );
          }),
      ],
    );
  }

  Widget _skillScoreboardCard(_SkillMeta meta, List<GetScoreboardDto> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: meta.lightColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: meta.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: meta.lightColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(meta.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  meta.title,
                  style: TextStyle(
                    color: meta.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: meta.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length} oyuncu',
                    style: TextStyle(
                      color: meta.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Bu alanda henüz skor yok.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: Color(0xFFF1F5F9),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final levelName = _levelNames[item.levelType] ?? '?';
                Widget rankWidget;
                if (index == 0) {
                  rankWidget = const Text('🥇', style: TextStyle(fontSize: 18));
                } else if (index == 1) {
                  rankWidget = const Text('🥈', style: TextStyle(fontSize: 18));
                } else if (index == 2) {
                  rankWidget = const Text('🥉', style: TextStyle(fontSize: 18));
                } else {
                  rankWidget = Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 28, child: Center(child: rankWidget)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.username,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: meta.lightColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                levelName,
                                style: TextStyle(
                                  color: meta.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [meta.color, meta.color.withOpacity(0.75)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 3),
                            Text(
                              '${item.point} XP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SkillMeta {
  final int skillType;
  final String title;
  final String emoji;
  final Color color;
  final Color lightColor;

  const _SkillMeta(
    this.skillType,
    this.title,
    this.emoji,
    this.color,
    this.lightColor,
  );
}
