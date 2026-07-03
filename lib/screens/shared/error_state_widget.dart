import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, required this.message, this.onRetry, this.actionLabel = 'Tekrar Dene'});
  final String message;
  final VoidCallback? onRetry;
  final String actionLabel;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge), if (onRetry != null) ...[const SizedBox(height: 16), FilledButton(onPressed: onRetry, child: Text(actionLabel))]])));
}
