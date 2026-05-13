import 'package:flutter/material.dart';

import '../models/bus.dart';
import '../utils/app_theme.dart';
import '../widgets/bus_detail_card.dart';
import '../widgets/bus_list_card.dart';

class RoutesScreen extends StatefulWidget {
  final List<Bus> buses;
  final ValueChanged<Bus> onBusSelected;

  const RoutesScreen({
    super.key,
    required this.buses,
    required this.onBusSelected,
  });

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  String selectedSort = "ETA";
  Bus? selectedBus;

  List<Bus> get sortedBuses {
    final sorted = [...widget.buses];

    switch (selectedSort) {
      case "ETA":
        sorted.sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));
        break;
      case "Crowd":
        sorted.sort(
          (a, b) => crowdRank(b.crowdLevel).compareTo(crowdRank(a.crowdLevel)),
        );
        break;
      case "Occupancy":
        sorted.sort((a, b) => b.occupancyPercent.compareTo(a.occupancyPercent));
        break;
    }

    return sorted;
  }

  void _selectBus(Bus bus) {
    setState(() {
      selectedBus = bus;
    });

    widget.onBusSelected(bus);
  }

  @override
  Widget build(BuildContext context) {
    final routes = sortedBuses;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            "Available Routes",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Compare ETA, route crowding and occupancy before boarding.",
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _sortChip("ETA", Icons.timer_rounded),
              _sortChip("Crowd", Icons.groups_rounded),
              _sortChip("Occupancy", Icons.speed_rounded),
            ],
          ),
          const SizedBox(height: 20),
          ...routes.map(
            (bus) => BusListCard(bus: bus, onTap: () => _selectBus(bus)),
          ),
          if (selectedBus != null) ...[
            const SizedBox(height: 14),
            const Text(
              "Route Details",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            BusDetailCard(bus: selectedBus!),
          ],
        ],
      ),
    );
  }

  Widget _sortChip(String label, IconData icon) {
    final selected = selectedSort == label;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: selected ? AppColors.electricBlue : AppColors.muted,
          ),
          const SizedBox(width: 6),
          Text("Sort by $label"),
        ],
      ),
      selected: selected,
      onSelected: (_) {
        setState(() {
          selectedSort = label;
        });
      },
      selectedColor: AppColors.electricBlue.withOpacity(0.24),
      backgroundColor: AppColors.cardDark,
      labelStyle: TextStyle(
        color: selected ? AppColors.electricBlue : AppColors.muted,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(
        color: selected ? AppColors.electricBlue : AppColors.border,
      ),
    );
  }
}
