import 'package:flutter/material.dart';

import '../models/bus.dart';
import '../utils/app_theme.dart';
import 'crowd_badge.dart';

class BusDetailCard extends StatelessWidget {
  final Bus bus;

  const BusDetailCard({super.key, required this.bus});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showAlternativeDialog(BuildContext context) {
    final hasAlternative = !bus.alternative.toLowerCase().contains(
      "no alternate",
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            "Smart Alternative",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            hasAlternative
                ? "Consider taking ${bus.alternative} for a less crowded journey."
                : "Comfortable ride expected. No alternate needed.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = crowdColor(bus.crowdLevel);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardDark.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroSection(color),
          const SizedBox(height: 14),
          _quickStatsRow(color),
          const SizedBox(height: 14),
          _stopTimeline(),
          const SizedBox(height: 14),
          _occupancyWidget(color),
          const SizedBox(height: 14),
          _aiPredictionWidget(),
          const SizedBox(height: 14),
          _recommendationWidget(context, color),
        ],
      ),
    );
  }

  Widget _heroSection(Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.24),
            AppColors.purple.withOpacity(0.16),
            AppColors.cardLight.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.electricBlue, AppColors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    bus.routeNo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        CrowdBadge(level: bus.crowdLevel),
                        _smallChip(
                          icon: Icons.auto_awesome_rounded,
                          text: "${bus.confidence}% AI",
                          color: AppColors.electricBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      bus.direction,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bus.busId,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _heroMiniInfo(
                  icon: Icons.timer_rounded,
                  title: "ETA",
                  value: bus.eta,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroMiniInfo(
                  icon: Icons.confirmation_number_rounded,
                  title: "Fare",
                  value: bus.fare,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroMiniInfo(
                  icon: Icons.directions_bus_rounded,
                  title: "Type",
                  value: bus.busType,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickStatsRow(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.people_alt_rounded,
              label: "Passengers",
              value: "${bus.occupancy}/${bus.capacity}",
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.percent_rounded,
              label: "Occupied",
              value: "${bus.occupancyPercentageValue}%",
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.departure_board_rounded,
              label: "Departs",
              value: bus.departure,
              color: AppColors.electricBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _softCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.route_rounded, "Trip Flow"),
            const SizedBox(height: 16),
            _timelineItem(
              icon: Icons.my_location_rounded,
              title: "Current Stop",
              value: bus.currentStop,
              isFirst: true,
            ),
            _timelineItem(
              icon: Icons.near_me_rounded,
              title: "Next Stop",
              value: bus.nextStop,
            ),
            _timelineItem(
              icon: Icons.flag_rounded,
              title: "Destination",
              value: bus.destination,
              isLast: true,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallChip(
                  icon: Icons.pin_drop_rounded,
                  text: bus.platform,
                  color: AppColors.purple,
                ),
                _smallChip(
                  icon: Icons.schedule_rounded,
                  text: "Updated ${_formatTimestamp(bus.timestamp)}",
                  color: AppColors.electricBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _occupancyWidget(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _softCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.speed_rounded, "Live Occupancy"),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: bus.occupancyPercent.clamp(0, 1),
                        strokeWidth: 9,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      Center(
                        child: Text(
                          "${bus.occupancyPercentageValue}%",
                          style: TextStyle(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${bus.occupancy} passengers detected",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Capacity: ${bus.capacity} passengers",
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: bus.occupancyPercent.clamp(0, 1),
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiPredictionWidget() {
    final futureColor = crowdColor(bus.futureCrowd);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.purple.withOpacity(0.18),
              AppColors.electricBlue.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.purple.withOpacity(0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.auto_awesome_rounded, "AI Future Crowd"),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallChip(
                  icon: Icons.trending_up_rounded,
                  text: "Future: ${bus.futureCrowd}",
                  color: futureColor,
                ),
                _smallChip(
                  icon: Icons.schedule_rounded,
                  text: "Next 10–20 min",
                  color: AppColors.electricBlue,
                ),
                _smallChip(
                  icon: Icons.verified_rounded,
                  text: "${bus.confidence}% confidence",
                  color: AppColors.purple,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              bus.prediction,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recommendationWidget(BuildContext context, Color color) {
    final hasAlternative = !bus.alternative.toLowerCase().contains(
      "no alternate",
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.26)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.recommend_rounded, "Recommended Action"),
            const SizedBox(height: 10),
            Text(
              bus.recommendedAction,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasAlternative
                  ? "Consider ${bus.alternative} for a less crowded journey."
                  : "Comfortable ride expected. No alternate needed.",
              style: const TextStyle(
                color: AppColors.white,
                height: 1.4,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showSnack(
                        context,
                        "Recommendation selected: ${bus.recommendedAction}",
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text("Use"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAlternativeDialog(context),
                    icon: const Icon(Icons.alt_route_rounded),
                    label: const Text("Alternate"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(
                        color: AppColors.white.withOpacity(0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroMiniInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.electricBlue, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required IconData icon,
    required String title,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.electricBlue.withOpacity(0.14),
              child: Icon(icon, color: AppColors.electricBlue, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: AppColors.electricBlue.withOpacity(0.22),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 1 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.electricBlue, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _softCardDecoration() {
    return BoxDecoration(
      color: AppColors.cardLight.withOpacity(0.68),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return timestamp;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 95),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardLight.withOpacity(0.64),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
