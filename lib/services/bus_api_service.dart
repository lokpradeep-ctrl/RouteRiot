import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bus.dart';

class BusApiService {
  static const String baseUrl = "http://10.119.224.185:8000";

  Future<List<Bus>> fetchBusStatus() async {
    final url = Uri.parse("$baseUrl/bus-status");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded.map((item) {
          return Bus.fromJson(_addFallbackFields(item));
        }).toList();
      }

      if (decoded is Map<String, dynamic>) {
        return [Bus.fromJson(_addFallbackFields(decoded))];
      }

      throw Exception("Unexpected API response format");
    } else {
      throw Exception("Failed to load bus status: ${response.statusCode}");
    }
  }

  Map<String, dynamic> _addFallbackFields(Map<String, dynamic> json) {
    return {
      "bus_id": json["bus_id"] ?? "BMTC_UNKNOWN",
      "route_no": json["route_no"] ?? "N/A",
      "occupancy": json["occupancy"] ?? 0,
      "capacity": json["capacity"] ?? 60,
      "timestamp": json["timestamp"] ?? DateTime.now().toIso8601String(),
      "crowd_level": json["crowd_level"] ?? "Low",
      "prediction": json["prediction"] ?? "Prediction unavailable",
      "future_crowd": json["future_crowd"] ?? json["crowd_level"] ?? "Low",
      "confidence": json["confidence"] ?? 80,
      "alternative": json["alternative"] ?? "No alternate needed",

      // UI fallback values if backend does not send them yet
      "current_stop": json["current_stop"] ?? "Current stop updating",
      "next_stop": json["next_stop"] ?? "Next stop updating",
      "destination": json["destination"] ?? "Destination updating",
      "eta": json["eta"] ?? "8 min",
      "departure": json["departure"] ?? "--:--",
      "direction": json["direction"] ?? "Direction updating",
      "recommended_action":
          json["recommended_action"] ??
          _getRecommendedAction(json["crowd_level"] ?? "Low"),
      "platform": json["platform"] ?? "Stop updating",
      "bus_type": json["bus_type"] ?? "BMTC",
      "fare": json["fare"] ?? "₹--",
    };
  }

  String _getRecommendedAction(String crowdLevel) {
    switch (crowdLevel.toLowerCase()) {
      case "high":
        return "Wait / Take Alternative";
      case "moderate":
        return "Board if necessary";
      case "low":
        return "Board Now";
      default:
        return "Check before boarding";
    }
  }
}
