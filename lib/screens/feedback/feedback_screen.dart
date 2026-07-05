import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

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
              child: Text('Aklımıza gelmeyen bir ihtiyaç, yanlış eczane bilgisi veya tasarım önerisi varsa buradan gönderebilirsin.'),
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
            onPressed: _sendFeedback,
            icon: const Icon(Icons.send),
            label: const Text('Geri bildirimi gönder'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Form linki eklenirse geri bildirimler forma gider. Link yoksa mail taslağı açılır.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _sendFeedback() async {
    final message = controller.text.trim();
    final configuredUrl = dotenv.maybeGet('FEEDBACK_URL')?.trim() ?? '';
    final uri = configuredUrl.isNotEmpty ? Uri.parse(configuredUrl) : _mailUri(message);

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;

    if (opened) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geri bildirim bağlantısı açıldı.')));
      controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bağlantı açılamadı. Daha sonra tekrar deneyelim.')));
    }
  }

  Uri _mailUri(String message) {
    final body = [
      'Konu: $topic',
      '',
      message.isEmpty ? 'Mesaj: ' : 'Mesaj: $message',
      '',
      'Eczanem uygulamasından gönderildi.',
    ].join('\n');

    return Uri(
      scheme: 'mailto',
      path: 'efeyildiztas01@gmail.com',
      queryParameters: {
        'subject': 'Eczanem geri bildirim - $topic',
        'body': body,
      },
    );
  }
}
