import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF07111F);
  static const Color background2 = Color(0xFF0B1730);
  static const Color cardDark = Color(0xFF101B2E);
  static const Color cardLight = Color(0xFF17243A);

  static const Color electricBlue = Color(0xFF38BDF8);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color white = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF94A3B8);
  static const Color border = Color(0x2238BDF8);

  static const Color low = Color(0xFF22C55E);
  static const Color moderate = Color(0xFFF59E0B);
  static const Color high = Color(0xFFEF4444);
}

Color crowdColor(String level) {
  switch (level.toLowerCase()) {
    case "high":
      return AppColors.high;
    case "moderate":
      return AppColors.moderate;
    case "low":
      return AppColors.low;
    default:
      return AppColors.electricBlue;
  }
}

IconData crowdIcon(String level) {
  switch (level.toLowerCase()) {
    case "high":
      return Icons.warning_rounded;
    case "moderate":
      return Icons.error_outline_rounded;
    case "low":
      return Icons.check_circle_outline_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

int crowdRank(String level) {
  switch (level.toLowerCase()) {
    case "low":
      return 1;
    case "moderate":
      return 2;
    case "high":
      return 3;
    default:
      return 0;
  }
}
