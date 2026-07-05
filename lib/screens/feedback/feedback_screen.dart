import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final controller = TextEditingController();
  String topic = 'Öneri';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const topics = ['Öneri', 'Hata', 'Eksik eczane', 'İlaç takibi', 'Tasarım'];
    return Scaffold(
      appBar: AppBar(title: const Text('Geri Bildirim')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: AppColors.primaryLight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aklımıza gelmeyen bir ihtiyaç, yanlış eczane bilgisi veya tasarım önerisi varsa buradan not alabiliriz.'),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: topic,
            decoration: const InputDecoration(labelText: 'Konu'),
            items: topics.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) => setState(() => topic = value ?? topic),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(labelText: 'Mesajınız', hintText: 'Örn: İlçe listesinde şu eksik...'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geri bildirim kaydedildi. Gönderim bağlantısı sonraki aşamada eklenecek.')),
              );
              controller.clear();
            },
            icon: const Icon(Icons.send),
            label: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
