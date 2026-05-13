import 'package:flutter/material.dart';

import 'data/mock_bus_data.dart';
import 'models/bus.dart';
import 'screens/alerts_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/routes_screen.dart';
import 'screens/search_screen.dart';
import 'services/bus_api_service.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const RouteRiotApp());
}

class RouteRiotApp extends StatelessWidget {
  const RouteRiotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Riot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.electricBlue,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),

      // Keeps the app looking like a real 9:16 mobile app
      // even when opened in Chrome/web.
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isWideScreen = constraints.maxWidth > 600;

            if (!isWideScreen) {
              return child ?? const SizedBox.shrink();
            }

            final double phoneWidth = (constraints.maxHeight * 9 / 16).clamp(
              360.0,
              430.0,
            );

            return Container(
              color: AppColors.background,
              child: Center(
                child: Container(
                  width: phoneWidth,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.electricBlue.withOpacity(0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
        );
      },

      // First page before dashboard.
      home: const LandingScreen(),

      // If you want to skip Get Started page, use this instead:
      // home: const RouteRiotShell(),
    );
  }
}

class RouteRiotShell extends StatefulWidget {
  const RouteRiotShell({super.key});

  @override
  State<RouteRiotShell> createState() => _RouteRiotShellState();
}

class _RouteRiotShellState extends State<RouteRiotShell> {
  int currentIndex = 0;

  late List<Bus> buses;
  Bus? selectedBus;

  String lastUpdated = "Just now";
  bool isLoading = true;
  String? errorMessage;

  final BusApiService apiService = BusApiService();

  @override
  void initState() {
    super.initState();
    buses = [];
    _loadBusData();
  }

  Bus _getHighestCrowdBus(List<Bus> busList) {
    final sorted = [...busList];
    sorted.sort((a, b) => b.occupancyPercent.compareTo(a.occupancyPercent));
    return sorted.first;
  }

  Future<void> _loadBusData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final liveBuses = await apiService.fetchBusStatus();

      if (liveBuses.isEmpty) {
        throw Exception("Backend returned empty bus list");
      }

      setState(() {
        buses = liveBuses;
        selectedBus = _getHighestCrowdBus(buses);
        lastUpdated = "Live from backend";
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        buses = mockBusData.map((item) => Bus.fromJson(item)).toList();
        selectedBus = _getHighestCrowdBus(buses);
        errorMessage = "Backend unavailable. Showing mock data.";
        lastUpdated = "Mock fallback";
        isLoading = false;
      });
    }
  }

  void selectBus(Bus bus) {
    setState(() {
      selectedBus = bus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Selected route ${bus.routeNo}"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void refreshMockData() {
    _loadBusData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Refreshing live backend data..."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.electricBlue),
                SizedBox(height: 18),
                Text(
                  "Loading live bus data...",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Connecting to backend",
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (selectedBus == null || buses.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.high,
                      size: 48,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "No bus data available",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage ?? "Please check backend connection.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: _loadBusData,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Try Again"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        buses: buses,
        selectedBus: selectedBus!,
        lastUpdated: lastUpdated,
        onRefresh: refreshMockData,
        onBusSelected: selectBus,
      ),
      SearchScreen(buses: buses, onBusSelected: selectBus),
      RoutesScreen(buses: buses, onBusSelected: selectBus),
      AlertsScreen(buses: buses, onBusSelected: selectBus),
    ];

    return Scaffold(
      body: Column(
        children: [
          if (errorMessage != null)
            SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.moderate.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.moderate.withOpacity(0.28),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.moderate,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.moderate,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(index: currentIndex, children: screens),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          backgroundColor: AppColors.cardDark,
          indicatorColor: AppColors.electricBlue.withOpacity(0.18),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: "Search",
            ),
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route),
              label: "Routes",
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_none),
              selectedIcon: Icon(Icons.notifications),
              label: "Alerts",
            ),
          ],
        ),
      ),
    );
  }
}
