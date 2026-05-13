import 'package:flutter/material.dart';

import '../models/bus.dart';
import '../utils/app_theme.dart';
import '../widgets/bus_detail_card.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatelessWidget {
  final List<Bus> buses;
  final Bus selectedBus;
  final String lastUpdated;
  final VoidCallback onRefresh;
  final ValueChanged<Bus> onBusSelected;

  const HomeScreen({
    super.key,
    required this.buses,
    required this.selectedBus,
    required this.lastUpdated,
    required this.onRefresh,
    required this.onBusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final highCrowdCount = buses
        .where((bus) => bus.crowdLevel.toLowerCase() == "high")
        .length;

    final leastCrowded = [...buses]
      ..sort((a, b) => a.occupancyPercent.compareTo(b.occupancyPercent));
    final fastest = [...buses]
      ..sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _header(),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(
                title: "Total buses tracked",
                value: buses.length.toString(),
                icon: Icons.directions_bus_filled_rounded,
                color: AppColors.electricBlue,
              ),
              SummaryCard(
                title: "High crowd alerts",
                value: highCrowdCount.toString(),
                icon: Icons.warning_amber_rounded,
                color: AppColors.high,
              ),
              SummaryCard(
                title: "Least crowded route",
                value: leastCrowded.first.routeNo,
                icon: Icons.airline_seat_recline_normal_rounded,
                color: AppColors.low,
              ),
              SummaryCard(
                title: "Fastest arriving bus",
                value: fastest.first.routeNo,
                icon: Icons.timer_rounded,
                color: AppColors.moderate,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            "Highlighted Live Bus",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          BusDetailCard(bus: selectedBus),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardDark, AppColors.background2.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.directions_bus_filled_rounded,
                color: AppColors.electricBlue,
              ),
              Text(
                "Route Riot",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Smart BMTC Occupancy Prediction",
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.low.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.low.withOpacity(0.35)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_tethering_rounded,
                      color: AppColors.low,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Connected",
                      style: TextStyle(
                        color: AppColors.low,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Last updated: $lastUpdated",
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
