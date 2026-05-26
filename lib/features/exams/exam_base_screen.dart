import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/exam_type.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/listening/listening_content_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/speaking/speaking_content_dto.dart';
import 'package:flutter_turkce_ogrenme_application/data/models/writing/writing_task_dto.dart';
import 'package:flutter_turkce_ogrenme_application/features/exams/exam_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/exams/exam_state.dart';
import 'package:flutter_turkce_ogrenme_application/features/home/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

const _primary = Color(0xFF1565C0);
const _primaryDark = Color(0xFF0D47A1);
const _accent = Color(0xFF0288D1);
const _surface = Color(0xFFF0F6FF);
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF0D2137);
const _textSecondary = Color(0xFF6B7280);
const _success = Color(0xFF10B981);
const _error = Color(0xFFEF4444);

class ExamBaseScreen extends ConsumerStatefulWidget {
  final ExamType type;
  final String level;

  const ExamBaseScreen({super.key, required this.type, required this.level});

  @override
  ConsumerState<ExamBaseScreen> createState() => _ExamBaseScreenState();
}

class _ExamBaseScreenState extends ConsumerState<ExamBaseScreen>
    with TickerProviderStateMixin {
  String? _selectedAnswer;
  bool _answered = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  final TextEditingController _writingController = TextEditingController();

  // ── TTS state ─────────────────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  bool _ttsPlaying = false;
  double _ttsProgress = 0.0; // 0.0 – 1.0
  int _ttsTotalChars = 0;
  int _ttsSpokenChars = 0;
  String? _lastSpokenText; // hangi soru için TTS başlatıldı
  bool _isPaused = false; // duraklatıldı mı?
  int _pausedAtChars = 0; // duraklatma anındaki karakter pozisyonu

  ///Soru Sayısı
  int wsQuestionCount = 2;
  int rlQuestionCount = 5;
  int questionCount = 0;

  ///

  // ── Speaking / Recorder state ─────────────────────────────────────────────
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _recordingDone = false;
  String? _recordedFilePath;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _initTts();
    _initCountByType();
  }

  void _initCountByType() {
    switch (widget.type) {
      case ExamType.listening:
        questionCount = rlQuestionCount;
        break;
      case ExamType.reading:
        questionCount = rlQuestionCount;
        break;
      case ExamType.writing:
        questionCount = wsQuestionCount;
        break;
      case ExamType.speaking:
        questionCount = wsQuestionCount;
        break;
    }
  }

  void _initTts() async {
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      if (mounted) setState(() => _ttsPlaying = true);
    });

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _ttsPlaying = false;
          _ttsProgress = 1.0;
        });
      }
    });

    _tts.setCancelHandler(() {
      if (mounted) setState(() => _ttsPlaying = false);
    });

    _tts.setProgressHandler((text, startOffset, endOffset, word) {
      if (mounted && _ttsTotalChars > 0) {
        setState(() {
          if (_isPaused && endOffset < _pausedAtChars) {
            // TTS henüz duraklatılan noktaya ulaşmadı — bar'ı o noktada tut
            _ttsSpokenChars = _pausedAtChars;
          } else {
            if (_isPaused) _isPaused = false; // TTS yakaladı, normal moda geç
            _ttsSpokenChars = endOffset;
          }
          _ttsProgress = (_ttsSpokenChars / _ttsTotalChars).clamp(0.0, 1.0);
        });
      }
    });
  }

  Future<void> _speakOrPause(String text) async {
    if (_ttsPlaying) {
      // Duraklatırken mevcut pozisyonu kaydet
      _pausedAtChars = _ttsSpokenChars;
      _isPaused = true;
      await _tts.pause();
      setState(() => _ttsPlaying = false);
    } else {
      if (_lastSpokenText != text) {
        // Yeni metin — her şeyi sıfırla
        _lastSpokenText = text;
        _ttsTotalChars = text.length;
        _ttsSpokenChars = 0;
        _ttsProgress = 0.0;
        _isPaused = false;
        _pausedAtChars = 0;
      }
      // _isPaused = true ise progressHandler pozisyonu koruyacak
      await _tts.speak(text);
    }
  }

  Future<void> _stopTts() async {
    await _tts.stop();
    if (mounted) {
      setState(() {
        _ttsPlaying = false;
        _ttsProgress = 0.0;
        _ttsSpokenChars = 0;
        _lastSpokenText = null;
        _isPaused = false;
        _pausedAtChars = 0;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _writingController.dispose();
    _tts.stop();
    _recordingTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  void _resetForNewQuestion() {
    _stopTts();
    _writingController.clear();
    _recordingTimer?.cancel();
    if (_isRecording) _recorder.stop();
    setState(() {
      _selectedAnswer = null;
      _answered = false;
      _isRecording = false;
      _recordingDone = false;
      _recordedFilePath = null;
      _recordingSeconds = 0;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(examNotifierProvider((level: widget.level, type: widget.type)), (
      previous,
      next,
    ) {
      if (previous?.currentIndex != next.currentIndex) {
        final answer = next.givenAnswers[next.currentIndex];
        setState(() {
          _selectedAnswer = answer;
          _answered = answer != null;
          if (widget.type == ExamType.writing) {
            _writingController.text = answer ?? '';
          }
          if (widget.type == ExamType.speaking) {
            _recordingDone = answer == 'recorded';
          }
        });
      }
    });

    final state = ref.watch(
      examNotifierProvider((level: widget.level, type: widget.type)),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final state = ref.read(
          examNotifierProvider((level: widget.level, type: widget.type)),
        );
        if (state.isExamFinished) {
          Navigator.of(context).pop();
          return;
        }

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Emin misiniz?'),
            content: Text(
              '$questionCount soruyu tamamlamadan çıkarsanız ilerlemeniz kaydedilmeyecektir.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Çık', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          _stopTts();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: _surface,
        body: Column(
          children: [
            _buildGradientHeader(state),
            Expanded(child: _buildBody(state)),
            _buildNavigation(state),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildGradientHeader(ExamState state) {
    final visitedCount = state.visitedQuestions.length;
    final currentIndex = state.currentIndex;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryDark, _primary, _accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.level.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _examLabel(widget.type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Soru $currentIndex',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (visitedCount > 0)
                _buildQuestionDots(currentIndex, visitedCount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionDots(int currentIndex, int visitedCount) {
    final state = ref.read(
      examNotifierProvider((level: widget.level, type: widget.type)),
    );
    final maxVisited = state.visitedQuestions.keys.isEmpty
        ? currentIndex
        : state.visitedQuestions.keys.reduce((a, b) => a > b ? a : b);
    final totalDots = maxVisited > currentIndex ? maxVisited : currentIndex;

    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(totalDots, (i) {
            final qNum = i + 1;
            final isActive = qNum == currentIndex;
            final isVisited = ref
                .read(
                  examNotifierProvider((
                    level: widget.level,
                    type: widget.type,
                  )),
                )
                .visitedQuestions
                .containsKey(qNum);

            return GestureDetector(
              onTap: () {
                _resetForNewQuestion();
                ref
                    .read(
                      examNotifierProvider((
                        level: widget.level,
                        type: widget.type,
                      )).notifier,
                    )
                    .fetchQuestion(qNum);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 36 : 28,
                height: isActive ? 36 : 28,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : isVisited
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$qNum',
                    style: TextStyle(
                      color: isActive ? _primary : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isActive ? 14 : 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(ExamState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 16),
            Text(
              'Soru yükleniyor…',
              style: TextStyle(color: _textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: _error, size: 56),
            const SizedBox(height: 12),
            Text(
              'Hata: ${state.error}',
              style: const TextStyle(color: _error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state.questions.isEmpty) {
      return const Center(child: Text('Veri bulunamadı.'));
    }

    final data = state.questions.first;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildContentCard(data),
            const SizedBox(height: 20),
            _buildInteractionUI(data, state),
          ],
        ),
      ),
    );
  }

  // ── İçerik kartı ───────────────────────────────────────────────────────────
  Widget _buildContentCard(dynamic data) {
    switch (widget.type) {
      case ExamType.reading:
        return _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primary, _accent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data.title ?? 'Okuma Parçası',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                data.paragraph ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        );

      case ExamType.listening:
        // data: ListeningContentDto
        final listeningData = data as ListeningContentDto;
        final textToSpeak = listeningData.paragraph;
        return _buildListeningCard(textToSpeak, listeningData.title);

      case ExamType.writing:
        final task = data as WritingTaskDto;
        return _glassCard(
          child: Column(
            children: [
              const Icon(Icons.edit_note_rounded, color: _accent, size: 36),
              const SizedBox(height: 10),
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                task.instructions,
                style: const TextStyle(fontSize: 14, color: _textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      case ExamType.speaking:
        final speakingData = data as SpeakingContentDto;
        return _buildSpeakingInfoCard(speakingData);
    }
  }

  // ── Speaking bilgi kartı ──────────────────────────────────────────────────
  Widget _buildSpeakingInfoCard(SpeakingContentDto data) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık chip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFFE040FB)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.record_voice_over_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.title.isEmpty ? 'Konuşma Görevi' : data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Görev açıklaması
          Text(
            data.instructions,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: _textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          if (data.suggestedVocabulary.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Önerilen kelimeler:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: data.suggestedVocabulary.map((w) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B1FA2).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF7B1FA2).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    w,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B1FA2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          if (data.speakingTips.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...data.speakingTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates_rounded,
                      size: 14,
                      color: Color(0xFFE040FB),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Listening kartı (TTS + progress) ──────────────────────────────────────
  Widget _buildListeningCard(String text, String title) {
    return _glassCard(
      child: Column(
        children: [
          // Başlık chip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_primary, _accent]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.headphones_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title.isEmpty ? 'Dinleme Parçası' : title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Büyük play/pause butonu
          GestureDetector(
            onTap: () => _speakOrPause(text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _ttsPlaying
                      ? [const Color(0xFF0288D1), const Color(0xFF006064)]
                      : [_primary, _accent],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_ttsPlaying ? _accent : _primary).withOpacity(0.38),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _ttsPlaying
                    ? Icons.pause_rounded
                    : (_ttsProgress > 0.0 && _ttsProgress < 1.0)
                    ? Icons.play_arrow_rounded
                    : Icons.volume_up_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _ttsPlaying
                ? 'Dinleniyor…'
                : (_ttsProgress > 0.0 && _ttsProgress < 1.0)
                ? 'Devam et'
                : 'Dinlemek için dokun',
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          // İlerleme çubuğu
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _ttsProgress),
                  duration: const Duration(milliseconds: 200),
                  builder: (ctx, val, _) => LinearProgressIndicator(
                    value: val,
                    minHeight: 7,
                    backgroundColor: _primary.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(_ttsProgress * 100).toInt()}%',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Yeniden başlat butonu (tamamlandıktan sonra)
          if (_ttsProgress >= 1.0) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () async {
                await _tts.stop();
                setState(() {
                  _ttsProgress = 0.0;
                  _ttsSpokenChars = 0;
                  _lastSpokenText = null;
                });
                await Future.delayed(const Duration(milliseconds: 100));
                _speakOrPause(text);
              },
              icon: const Icon(Icons.replay_rounded, size: 16, color: _accent),
              label: const Text(
                'Tekrar dinle',
                style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Speaking kayıt metodları ──────────────────────────────────────────────
  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mikrofon izni verilmedi.')),
        );
      }
      return;
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/speaking_${DateTime.now().millisecondsSinceEpoch}.mp3';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordingSeconds++);
    });
    setState(() {
      _isRecording = true;
      _recordingDone = false;
      _recordedFilePath = path;
      _recordingSeconds = 0;
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    await _recorder.stop();
    setState(() => _isRecording = false);
  }

  Future<void> _submitSpeaking(String topic, String instructions) async {
    if (_recordedFilePath == null) return;

    setState(() => _answered = true);
    await ref
        .read(
          examNotifierProvider((
            level: widget.level,
            type: widget.type,
          )).notifier,
        )
        .submitSpeakingAnswer(_recordedFilePath!, topic, instructions);
    if (mounted) setState(() => _recordingDone = true);
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  // ── Şıklar / etkileşim ────────────────────────────────────────────────────
  Widget _buildInteractionUI(dynamic data, ExamState state) {
    if (widget.type == ExamType.speaking) {
      final speakingData = data as SpeakingContentDto;
      return _buildSpeakingRecorderUI(speakingData, state);
    }

    if (widget.type == ExamType.writing) {
      final task = data as WritingTaskDto;
      return Column(
        children: [
          _glassCard(
            child: TextField(
              controller: _writingController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Cevabınızı buraya yazın…',
                hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6)),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: _textPrimary, fontSize: 15),
            ),
          ),
          if (!_answered) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final text = _writingController.text.trim();
                  if (text.isEmpty) return;

                  setState(() => _answered = true);
                  try {
                    await ref
                        .read(
                          examNotifierProvider((
                            level: widget.level,
                            type: widget.type,
                          )).notifier,
                        )
                        .submitWritingAnswer(
                          text,
                          task.title,
                          task.instructions,
                        );
                    if (!mounted) return;
                  } catch (e) {
                    // Error handling is in state
                  }
                },
                child: const Text(
                  'Değerlendir',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            if (state.writingEvaluations[state.currentIndex] != null) ...[
              _buildEvaluationFeedbackUI(
                state.writingEvaluations[state.currentIndex]!,
              ),
            ] else ...[
              _glassCard(
                child: const Column(
                  children: [
                    Icon(Icons.check_circle, color: _success, size: 48),
                    SizedBox(height: 8),
                    Text(
                      "Cevabınız kaydedildi, ancak değerlendirme sonucu alınamadı.",
                      style: TextStyle(
                        color: _success,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      );
    }

    if (widget.type == ExamType.reading) {
      final question = data.questions[0];
      final options = (question.options as List).cast<String>();
      final correct = question.correctAnswer as String;
      return _buildOptionsUI(
        question.text,
        options,
        correct,
        question.explanation,
      );
    }

    if (widget.type == ExamType.listening) {
      final listeningData = data as ListeningContentDto;
      final question = listeningData.questions[0];
      final options = question.options;
      final correct = question.correctAnswer;
      return _buildOptionsUI(
        question.text,
        options,
        correct,
        question.explanation,
      );
    }

    return const SizedBox.shrink();
  }

  // ── Writing & Speaking Evaluation UI ───────────────────────────────────────────────────
  Widget _buildEvaluationFeedbackUI(dynamic eval) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: _success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Değerlendirme Sonucu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      'Puan: ${eval.score}/100 • Seviye: ${eval.detectedLevel.isNotEmpty ? eval.detectedLevel : widget.level}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFeedbackSection(
            'Geri Bildirim',
            eval.feedback,
            Icons.feedback_outlined,
            _accent,
          ),
          const SizedBox(height: 16),
          _buildFeedbackSection(
            'Düzeltilmiş Metin',
            eval.correctedText,
            Icons.edit_note_outlined,
            _primary,
          ),
          if (eval.motivationMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      eval.motivationMessage,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFC2410C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: _textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Speaking kayıt UI ─────────────────────────────────────────────────────
  Widget _buildSpeakingRecorderUI(SpeakingContentDto data, ExamState state) {
    const Color speakingPurple = Color(0xFF7B1FA2);
    const Color speakingPink = Color(0xFFE040FB);

    if (_recordingDone || _answered) {
      final eval = state.speakingEvaluations[state.currentIndex];

      if (eval != null) {
        return _buildEvaluationFeedbackUI(eval);
      }

      return _glassCard(
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: _success, size: 52),
            const SizedBox(height: 10),
            const Text(
              'Cevabınız kaydedildi!',
              style: TextStyle(
                color: _success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Sıradaki soruya geçebilirsiniz.',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _glassCard(
          child: Column(
            children: [
              // Süre göstergesi
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isRecording
                        ? [const Color(0xFFE53935), const Color(0xFFE040FB)]
                        : [speakingPurple, speakingPink],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? Colors.red : speakingPurple)
                          .withOpacity(0.4),
                      blurRadius: _isRecording ? 28 : 16,
                      spreadRadius: _isRecording ? 4 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),

              const SizedBox(height: 10),

              // Sayaç
              if (_isRecording) ...[
                Text(
                  _formatSeconds(_recordingSeconds),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Kaydediliyor…',
                  style: TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ] else if (_recordedFilePath != null) ...[
                const Text(
                  'Kayıt tamamlandı ✔',
                  style: TextStyle(
                    color: _success,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                const Text(
                  'Mikrofona dokun ve konuşmaya başla',
                  style: TextStyle(color: _textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 18),

              // Kayıt başlat / durdur butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording
                        ? const Color(0xFFE53935)
                        : speakingPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: Icon(
                    _isRecording
                        ? Icons.stop_rounded
                        : Icons.fiber_manual_record_rounded,
                    size: 20,
                  ),
                  label: Text(
                    _isRecording ? 'Kaydı Durdur' : 'Kaydı Başlat',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Gönder butonu (sadece kayıt bittikten sonra)
        if (!_isRecording && _recordedFilePath != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () => _submitSpeaking(data.title, data.instructions),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Cevabı Gönder',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Ortak şık UI ─────────────────────────────────────────────────────────
  Widget _buildOptionsUI(
    String questionText,
    List<String> options,
    String correct,
    String explanation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Soru metni
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            questionText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
              height: 1.5,
            ),
          ),
        ),

        // Seçenekler
        ...options.asMap().entries.map((e) {
          final idx = e.key;
          final opt = e.value;
          final label = String.fromCharCode(65 + idx); // A, B, C, D

          Color cardColor = _cardBg;
          Color borderColor = Colors.transparent;
          Color labelColor = _primary;
          Widget? trailingIcon;

          if (_answered) {
            if (opt[0] == correct) {
              cardColor = _success.withOpacity(0.08);
              borderColor = _success;
              labelColor = _success;
              trailingIcon = const Icon(
                Icons.check_circle,
                color: _success,
                size: 20,
              );
            } else if (opt == _selectedAnswer) {
              cardColor = _error.withOpacity(0.08);
              borderColor = _error;
              labelColor = _error;
              trailingIcon = const Icon(Icons.cancel, color: _error, size: 20);
            }
          } else if (opt == _selectedAnswer) {
            cardColor = _primary.withOpacity(0.07);
            borderColor = _primary;
          }

          return GestureDetector(
            onTap: _answered
                ? null
                : () => setState(() => _selectedAnswer = opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opt,
                      style: const TextStyle(color: _textPrimary, fontSize: 14),
                    ),
                  ),
                  if (trailingIcon != null) trailingIcon,
                ],
              ),
            ),
          );
        }),

        // Cevapla butonu
        if (!_answered && _selectedAnswer != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                setState(() => _answered = true);
                final selected = _selectedAnswer;
                if (selected != null) {
                  try {
                    await ref
                        .read(
                          examNotifierProvider((
                            level: widget.level,
                            type: widget.type,
                          )).notifier,
                        )
                        .submitAnswer(selected, correct);
                    if (!mounted) return;
                  } catch (e) {
                    print("Hata oluştu: $e");
                  }
                }
              },
              child: const Text(
                'Cevapla',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],

        // Açıklama
        if (_answered) ...[
          const SizedBox(height: 12),
          _glassCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _selectedAnswer?[0] == correct
                      ? Icons.lightbulb_rounded
                      : Icons.info_outline_rounded,
                  color: _selectedAnswer?[0] == correct ? _success : _error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    explanation,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Navigasyon çubuğu ──────────────────────────────────────────────────────
  Widget _buildNavigation(ExamState state) {
    final notifier = ref.read(
      examNotifierProvider((level: widget.level, type: widget.type)).notifier,
    );

    final canGoBack = state.currentIndex > 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: _cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: canGoBack ? 1.0 : 0.3,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: canGoBack
                  ? () {
                      _resetForNewQuestion();
                      notifier.previousQuestion();
                    }
                  : null,
              icon: const Icon(Icons.arrow_back_ios_new, size: 14),
              label: const Text(
                'Önceki',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (state.currentIndex == questionCount) {
                  // Son soru cevaplandı mı kontrol et
                  final answer = state.givenAnswers[questionCount];
                  /*final isWritingOrSpeaking =
                      widget.type == ExamType.writing ||
                      widget.type == ExamType.speaking;*/
                  // For speaking, answered flag is when recorded audio is there or eval exists.
                  // Wait, just check state.givenAnswers[10] != null, because we cache it now
                  if (answer == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen önce son soruyu cevaplayın.'),
                      ),
                    );
                    return;
                  }

                  final isSuccess = await notifier.finishExam();
                  if (context.mounted && isSuccess) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sınav bitirilirken hata oluştu.'),
                      ),
                    );
                  }
                } else {
                  _resetForNewQuestion();
                  notifier.nextQuestion();
                }
              },
              icon: Icon(
                state.currentIndex == questionCount
                    ? Icons.check
                    : Icons.arrow_forward_ios,
                size: 14,
              ),
              label: Text(
                state.currentIndex == questionCount
                    ? 'Sınavı Bitir'
                    : 'Sıradaki Soru',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Yardımcılar ───────────────────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  String _examLabel(ExamType type) {
    return switch (type) {
      ExamType.reading => 'Reading',
      ExamType.listening => 'Listening',
      ExamType.writing => 'Writing',
      ExamType.speaking => 'Speaking',
    };
  }
}
