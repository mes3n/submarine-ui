import 'package:flutter/material.dart';

class Palette {
  final Color backgorund;
  final Color highlight;
  final Color accent;
  final Color text;

  const Palette({
    required this.backgorund,
    required this.highlight,
    required this.accent,
    required this.text,
  });
}

const palette = Palette(
  backgorund: Color(0xFF000000),
  highlight: Color(0xFF121212),
  accent: Color(0xFF0288D1),
  text: Color(0xFFDDDDEE),
);
