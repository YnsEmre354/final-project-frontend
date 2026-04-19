/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/data/enum/exam_type.dart';

class ExamBaseScreen extends ConsumerWidget {
  final ExamType type;
  final String level;

  const ExamBaseScreen({super.key, required this.type, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${level.toUpperCase()} - ${type.name.toUpperCase()}'),
        centerTitle: true,
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata oluştu: $err')),
        data: (examData) {
          return Column(
            children: [
              // 1. Üst Kısım: Skill Tipine Göre Değişen Alan
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildSkillSpecificUI(type, examData),
                ),
              ),

              // 2. Alt Kısım: Sorular veya Yazma Alanı
              Expanded(flex: 3, child: _buildInteractionUI(type, examData)),

              // 3. Alt Buton
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Cevapları kontrol et veya gönder
                  },
                  child: const Text("Sınavı Tamamla"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Üst taraftaki "İçerik" alanı (Metin, Ses veya Soru başlığı)
  Widget _buildSkillSpecificUI(ExamType type, dynamic data) {
    switch (type) {
      case ExamType.reading:
        return SingleChildScrollView(
          child: Text(
            data.content, // AI'dan gelen Reading metni
            style: const TextStyle(fontSize: 16),
          ),
        );
      case ExamType.listening:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.audiotrack, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text("Ses dosyasını dinleyin"),
            // Buraya bir AudioPlayer widget'ı gelecek
            Slider(value: 0, onChanged: (v) {}),
          ],
        );
      case ExamType.writing:
        return Center(
          child: Text(
            "Topic: ${data.topic}", // AI'dan gelen Writing konusu
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        );
    }
  }

  // Alt taraftaki "Cevaplama" alanı
  Widget _buildInteractionUI(ExamType type, dynamic data) {
    if (type == ExamType.writing) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          maxLines: null,
          expands: true,
          decoration: InputDecoration(
            hintText: "Yazmaya başlayın...",
            border: OutlineInputBorder(),
          ),
        ),
      );
    } else {
      // Reading ve Listening için soru listesi
      return ListView.builder(
        itemCount: data.questions.length,
        itemBuilder: (context, index) {
          final q = data.questions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text("${index + 1}. ${q.question}"),
              subtitle: Column(
                children: (q.options as List).map((opt) {
                  return RadioListTile(
                    title: Text(opt),
                    value: opt,
                    groupValue: null,
                    onChanged: (val) {},
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    }
  }
}
*/
