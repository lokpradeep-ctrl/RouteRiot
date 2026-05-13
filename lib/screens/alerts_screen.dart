import 'package:flutter/material.dart';

import '../models/bus.dart';
import '../utils/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  final List<Bus> buses;
  final ValueChanged<Bus> onBusSelected;

  const AlertsScreen({
    super.key,
    required this.buses,
    required this.onBusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = buses.map((bus) => _AlertData.fromBus(bus)).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            "Crowd Alerts",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "AI-generated crowd warnings and redirection suggestions.",
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ...alerts.map((alert) => _alertCard(context, alert)),
        ],
      ),
    );
  }

  Widget _alertCard(BuildContext context, _AlertData alert) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        onBusSelected(alert.bus);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Opened alert for route ${alert.bus.routeNo}"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: alert.color.withOpacity(0.32)),
          boxShadow: [
            BoxShadow(
              color: alert.color.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: alert.color.withOpacity(0.16),
              child: Icon(alert.icon, color: alert.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.message,
                    style: const TextStyle(color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _tag(alert.bus.routeNo, AppColors.electricBlue),
                      _tag(alert.bus.crowdLevel, alert.color),
                      _tag("ETA ${alert.bus.eta}", AppColors.purple),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Redirection suggestion: ${alert.bus.alternative}",
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.alt_route_rounded),
                    label: const Text("Use Redirection Suggestion"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AlertData {
  final Bus bus;
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _AlertData({
    required this.bus,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  factory _AlertData.fromBus(Bus bus) {
    final level = bus.crowdLevel.toLowerCase();

    if (level == "high") {
      return _AlertData(
        bus: bus,
        title: "High crowd alert on Route ${bus.routeNo}",
        message:
            "Route ${bus.routeNo} is highly crowded. Consider ${bus.alternative}. ${bus.prediction}",
        icon: Icons.warning_rounded,
        color: AppColors.high,
      );
    }

    if (level == "moderate") {
      return _AlertData(
        bus: bus,
        title: "Moderate crowd on Route ${bus.routeNo}",
        message:
            "Route ${bus.routeNo} has moderate crowd. Boarding is possible, but monitor crowd buildup. Alternative: ${bus.alternative}.",
        icon: Icons.error_outline_rounded,
        color: AppColors.moderate,
      );
    }

    return _AlertData(
      bus: bus,
      title: "Comfortable ride on Route ${bus.routeNo}",
      message:
          "Route ${bus.routeNo} is comfortable right now. ${bus.recommendedAction}.",
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.low,
    );
  }
}
