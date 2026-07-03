import 'package:flutter/material.dart';

class MapListToggleButton extends StatelessWidget {
  const MapListToggleButton({super.key, required this.showList, required this.onPressed});
  final bool showList;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton.filled(onPressed: onPressed, tooltip: showList ? 'Haritayı göster' : 'Listeyi göster', icon: Icon(showList ? Icons.map : Icons.list));
}
