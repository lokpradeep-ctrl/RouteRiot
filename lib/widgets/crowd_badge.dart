import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class CrowdBadge extends StatelessWidget {
  final String level;

  const CrowdBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = crowdColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(crowdIcon(level), color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            level,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
