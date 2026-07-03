import 'package:flutter/material.dart';

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({super.key, required this.onSearch});
  final ValueChanged<String> onSearch;
  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Material(elevation: 1, borderRadius: BorderRadius.circular(8), child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'İl veya ilçe ara', prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(horizontal: 12)))), const SizedBox(width: 8), FilledButton(onPressed: () => widget.onSearch(controller.text.trim()), child: const Text('Ara'))])));
}
