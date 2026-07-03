import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, required this.message, this.actionLabel, this.onAction});
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.add_circle_outline, size: 56), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium), if (actionLabel != null) ...[const SizedBox(height: 16), FilledButton.icon(onPressed: onAction, icon: const Icon(Icons.add), label: Text(actionLabel!))]])));
}
