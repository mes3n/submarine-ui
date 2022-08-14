import 'package:flutter/material.dart';

class Palette {
  final Color backgorund;
  final Color lHighlight;
  final Color hHighlight;
  final Color accent;
  final Color text;

  const Palette({
    required this.backgorund,
    required this.lHighlight,
    required this.hHighlight,
    required this.accent,
    required this.text,
  });
}

const palette = Palette(
  backgorund: Color(0xFF000000),
  lHighlight: Color(0xFF121212),
  hHighlight: Color(0xFF242424),
  accent: Color(0xFF0288D1),
  text: Color(0xFFDDDDEE),
);
