import 'package:flutter/material.dart';

import '../models/bus.dart';
import '../utils/app_theme.dart';
import '../widgets/bus_detail_card.dart';
import '../widgets/bus_list_card.dart';

class SearchScreen extends StatefulWidget {
  final List<Bus> buses;
  final ValueChanged<Bus> onBusSelected;

  const SearchScreen({
    super.key,
    required this.buses,
    required this.onBusSelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = "All";
  Bus? selectedBus;

  final List<String> filters = [
    "All",
    "Low",
    "Moderate",
    "High",
    "Metro Option",
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Bus> get filteredBuses {
    final query = searchController.text.trim().toLowerCase();

    return widget.buses.where((bus) {
      final matchesSearch =
          query.isEmpty ||
          bus.routeNo.toLowerCase().contains(query) ||
          bus.busId.toLowerCase().contains(query);

      final matchesFilter = switch (selectedFilter) {
        "All" => true,
        "Low" => bus.crowdLevel.toLowerCase() == "low",
        "Moderate" => bus.crowdLevel.toLowerCase() == "moderate",
        "High" => bus.crowdLevel.toLowerCase() == "high",
        "Metro Option" => bus.hasMetroOption,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _selectBus(Bus bus) {
    setState(() {
      selectedBus = bus;
    });

    widget.onBusSelected(bus);
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredBuses;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            "Search BMTC Route",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Search by route number or bus ID before boarding.",
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: "Search bus route or bus ID",
              helperText: "Example: 500D, 365K, BMTC_301",
              helperStyle: const TextStyle(color: AppColors.muted),
              hintStyle: const TextStyle(color: AppColors.muted),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.electricBlue,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.electricBlue),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter;

              return ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
                selectedColor: AppColors.electricBlue.withOpacity(0.24),
                backgroundColor: AppColors.cardDark,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.electricBlue : AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.electricBlue : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          if (results.isEmpty)
            _emptyState()
          else
            ...results.map(
              (bus) => BusListCard(bus: bus, onTap: () => _selectBus(bus)),
            ),
          if (selectedBus != null) ...[
            const SizedBox(height: 14),
            const Text(
              "Selected Bus Details",
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

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.muted, size: 52),
          SizedBox(height: 12),
          Text(
            "No bus found",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Try searching with route number or bus ID.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
