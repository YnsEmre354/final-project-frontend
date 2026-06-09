import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_turkce_ogrenme_application/features/home/home_screen.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_provider.dart';
import 'package:flutter_turkce_ogrenme_application/features/placement/placement_state.dart';

class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() =>
      _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen> {
  final TextEditingController _writingController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void dispose() {
    _writingController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      _audioPath = '${dir.path}/placement_speaking.m4a';
      await _audioRecorder.start(const RecordConfig(), path: _audioPath!);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _audioPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placementProvider);
    final notifier = ref.read(placementProvider.notifier);
    const Color duoBlue = Color(0xFF1CB0F6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Seviye Belirleme Sınavı",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(state, notifier, duoBlue),
      ),
    );
  }

  Widget _buildContent(
    PlacementState state,
    PlacementNotifier notifier,
    Color primaryColor,
  ) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => notifier.nextStep(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (state.currentStep == PlacementStep.result) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                "Sınav Tamamlandı!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Belirlenen Seviyeniz: ${state.determinedLevel}",
                style: const TextStyle(fontSize: 20, color: Colors.blue),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text(
                  "Öğrenmeye Başla",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.currentStep == PlacementStep.saving) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Sonuçlarınız hesaplanıyor..."),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: _getProgress(state),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildCurrentQuestion(state, notifier, primaryColor)),
        ],
      ),
    );
  }

  double _getProgress(PlacementState state) {
    int total = 8; // 3R + 3L + 1W + 1S
    int current = 0;
    if (state.currentStep == PlacementStep.reading) {
      current = state.currentQuestionIndex;
    } else if (state.currentStep == PlacementStep.listening) {
      current = 3 + state.currentQuestionIndex;
    } else if (state.currentStep == PlacementStep.writing) {
      current = 6 + state.currentQuestionIndex;
    } else if (state.currentStep == PlacementStep.speaking) {
      current = 7 + state.currentQuestionIndex;
    }
    return current / total;
  }

  Widget _buildCurrentQuestion(
    PlacementState state,
    PlacementNotifier notifier,
    Color primaryColor,
  ) {
    if (state.currentStep == PlacementStep.reading &&
        state.currentReading != null) {
      final qData = state.currentReading!;
      final qIndex = state.currentQuestionIndex - 1;
      final q = (qIndex >= 0 && qIndex < qData.questions.length)
          ? qData.questions[qIndex]
          : null;

      if (q == null) return const SizedBox.shrink();

      return ListView(
        children: [
          const Text(
            "Okuma Bölümü",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(qData.paragraph, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
          Text(
            q.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ...q.options.map((opt) {
            final isSelected =
                state.readingAnswers[state.currentQuestionIndex] == opt;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => notifier.answerReading(opt),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? primaryColor.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Text(opt),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildNextButton(
            state,
            notifier,
            primaryColor,
            state.readingAnswers.containsKey(state.currentQuestionIndex),
          ),
        ],
      );
    } else if (state.currentStep == PlacementStep.listening &&
        state.currentListening != null) {
      final qData = state.currentListening!;
      final qIndex = state.currentQuestionIndex - 1;
      final q = (qIndex >= 0 && qIndex < qData.questions.length)
          ? qData.questions[qIndex]
          : null;

      if (q == null) return const SizedBox.shrink();

      return ListView(
        children: [
          const Text(
            "Dinleme Bölümü",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.headset, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Sınav ortamında metin okunur. Test amaçlı metni gösteriyoruz:",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            qData.paragraph,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          Text(
            q.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ...q.options.map((opt) {
            final isSelected =
                state.listeningAnswers[state.currentQuestionIndex] == opt;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => notifier.answerListening(opt),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? primaryColor.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Text(opt),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildNextButton(
            state,
            notifier,
            primaryColor,
            state.listeningAnswers.containsKey(state.currentQuestionIndex),
          ),
        ],
      );
    } else if (state.currentStep == PlacementStep.writing &&
        state.currentWriting != null) {
      final q = state.currentWriting!;
      return ListView(
        children: [
          const Text(
            "Yazma Bölümü",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            q.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(q.instructions, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          TextField(
            controller: _writingController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: "Cevabınızı buraya yazın...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_writingController.text.trim().isNotEmpty) {
                notifier.submitWriting(_writingController.text);
              }
            },
            child: const Text(
              "Gönder",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      );
    } else if (state.currentStep == PlacementStep.speaking &&
        state.currentSpeaking != null) {
      final q = state.currentSpeaking!;
      return ListView(
        children: [
          const Text(
            "Konuşma Bölümü",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            q.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(q.instructions, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              _isRecording ? "Kaydediliyor..." : "Kaydetmek için dokunun",
            ),
          ),
          const SizedBox(height: 40),
          if (_audioPath != null && !_isRecording)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => notifier.submitSpeaking(_audioPath!),
              child: const Text(
                "Gönder",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNextButton(
    PlacementState state,
    PlacementNotifier notifier,
    Color primaryColor,
    bool isEnabled,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? primaryColor : Colors.grey.shade300,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: isEnabled ? () => notifier.nextStep() : null,
      child: const Text(
        "Sonraki Soru",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
