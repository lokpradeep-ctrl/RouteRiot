class Bus {
  final String busId;
  final String routeNo;
  final int occupancy;
  final int capacity;
  final String timestamp;
  final String crowdLevel;
  final String prediction;
  final String futureCrowd;
  final int confidence;
  final String alternative;

  final String currentStop;
  final String nextStop;
  final String destination;
  final String eta;
  final String departure;
  final String direction;
  final String recommendedAction;
  final String platform;
  final String busType;
  final String fare;

  Bus({
    required this.busId,
    required this.routeNo,
    required this.occupancy,
    required this.capacity,
    required this.timestamp,
    required this.crowdLevel,
    required this.prediction,
    required this.futureCrowd,
    required this.confidence,
    required this.alternative,
    required this.currentStop,
    required this.nextStop,
    required this.destination,
    required this.eta,
    required this.departure,
    required this.direction,
    required this.recommendedAction,
    required this.platform,
    required this.busType,
    required this.fare,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      busId: json['bus_id'] ?? '',
      routeNo: json['route_no'] ?? '',
      occupancy: json['occupancy'] ?? 0,
      capacity: json['capacity'] ?? 60,
      timestamp: json['timestamp'] ?? '',
      crowdLevel: json['crowd_level'] ?? 'Low',
      prediction: json['prediction'] ?? '',
      futureCrowd: json['future_crowd'] ?? 'Low',
      confidence: json['confidence'] ?? 0,
      alternative: json['alternative'] ?? '',
      currentStop: json['current_stop'] ?? '',
      nextStop: json['next_stop'] ?? '',
      destination: json['destination'] ?? '',
      eta: json['eta'] ?? '',
      departure: json['departure'] ?? '',
      direction: json['direction'] ?? '',
      recommendedAction: json['recommended_action'] ?? '',
      platform: json['platform'] ?? '',
      busType: json['bus_type'] ?? '',
      fare: json['fare'] ?? '',
    );
  }

  double get occupancyPercent {
    if (capacity == 0) return 0;
    return occupancy / capacity;
  }

  int get occupancyPercentageValue {
    return (occupancyPercent * 100).round();
  }

  int get etaMinutes {
    final value = eta.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(value) ?? 999;
  }

  bool get hasMetroOption {
    return alternative.toLowerCase().contains("metro");
  }

  Bus copyWith({String? timestamp}) {
    return Bus(
      busId: busId,
      routeNo: routeNo,
      occupancy: occupancy,
      capacity: capacity,
      timestamp: timestamp ?? this.timestamp,
      crowdLevel: crowdLevel,
      prediction: prediction,
      futureCrowd: futureCrowd,
      confidence: confidence,
      alternative: alternative,
      currentStop: currentStop,
      nextStop: nextStop,
      destination: destination,
      eta: eta,
      departure: departure,
      direction: direction,
      recommendedAction: recommendedAction,
      platform: platform,
      busType: busType,
      fare: fare,
    );
  }
}
