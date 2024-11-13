import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

// Mocking GeoPoint and Distance classes
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint(this.latitude, this.longitude);
}

class Distance {
  double as(LengthUnit unit, LatLng start, LatLng end) {
    var dLat = _degToRad(end.latitude - start.latitude);
    var dLon = _degToRad(end.longitude - start.longitude);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(start.latitude)) * cos(_degToRad(end.latitude)) *
        sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var radius = 6371.0; // Radius of the Earth in kilometers
    return radius * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180.0);
  }
}

bool _isNearby(LatLng currentLocation, GeoPoint location) {
  if (currentLocation == null) return false;
  final distance = Distance().as(
    LengthUnit.Kilometer,
    currentLocation,
    LatLng(location.latitude, location.longitude),
  );
  print('Calculated Distance: $distance km');
  return distance <= 50.0; // Nearby if distance is less than or equal to 50 km
}

class Promotion {
  final bool status;

  Promotion({required this.status});
}

class PromotionProvider {
  Future<List<Promotion>> getPromotionsByRestaurantId(int id) async {
    return [
      Promotion(status: true),  // Active promotion
      Promotion(status: false), // Inactive promotion
    ];
  }
}

Future<List<Promotion>> _fetchPromotions(
    PromotionProvider promotionProvider, String filterStatus) async {
  List<Promotion> promotions = await promotionProvider.getPromotionsByRestaurantId(1);

  if (filterStatus == 'Active') {
    return promotions.where((promotion) => promotion.status).toList();
  } else if (filterStatus == 'Inactive') {
    return promotions.where((promotion) => !promotion.status).toList();
  } else {
    return promotions;  // 'All'
  }
}

void main() {
  group('_fetchPromotions', () {
    test('should return active promotions when filter is Active', () async {
      final promotionProvider = PromotionProvider();
      final result = await _fetchPromotions(promotionProvider, 'Active');

      print('Testing Active filter...');
      print('Number of active promotions: ${result.length}');
      expect(result.length, 1);
      expect(result[0].status, true); // Active promotion
      print('Active promotion found: ${result[0].status}');
    });

    test('should return inactive promotions when filter is Inactive', () async {
      final promotionProvider = PromotionProvider();
      final result = await _fetchPromotions(promotionProvider, 'Inactive');

      print('Testing Inactive filter...');
      print('Number of inactive promotions: ${result.length}');
      expect(result.length, 1);
      expect(result[0].status, false); // Inactive promotion
      print('Inactive promotion found: ${result[0].status}');
    });

    test('should return all promotions when filter is All', () async {
      final promotionProvider = PromotionProvider();
      final result = await _fetchPromotions(promotionProvider, 'All');

      print('Testing All filter...');
      print('Number of all promotions: ${result.length}');
      expect(result.length, 2);
      print('All promotions: ${result.map((promo) => promo.status).toList()}');
    });
  });

  group('_isNearby', () {
    late LatLng currentLocation;

    setUp(() {
      // Initialize current location
      currentLocation = LatLng(0.0, 0.0); // Example location: Latitude 0, Longitude 0
    });

    test('should return true for nearby location', () {
      final geoPoint = GeoPoint(0.0, 0.1); // Simulated nearby location (within 50 km)
      final result = _isNearby(currentLocation, geoPoint);

      print('Expected: true');
      print('Actual: $result');
      expect(result, isTrue); // Expect true since the distance is less than 50 km
    });

    test('should return false for distant location', () {
      final geoPoint = GeoPoint(0.0, 10.0); // Simulated distant location (more than 50 km)
      final result = _isNearby(currentLocation, geoPoint);

      print('Expected: false');
      print('Actual: $result');
      expect(result, isFalse); // Expect false since the distance is greater than 50 km
    });
  });

  test('_updateTitleCounts and _updateSubtitleCounts update counts correctly', () {
    // Variables to hold character and word counts
    int _titleCharCount = 0;
    int _titleWordCount = 0;
    int _subtitleCharCount = 0;
    int _subtitleWordCount = 0;

    // Function to update title counts
    void _updateTitleCounts(String text) {
      _titleCharCount = text.length;
      _titleWordCount = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    }

    // Function to update subtitle counts
    void _updateSubtitleCounts(String text) {
      _subtitleCharCount = text.length;
      _subtitleWordCount = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    }

    // Test for _updateTitleCounts
    _updateTitleCounts('This is a test title');
    expect(_titleCharCount, 20); // 20 characters
    expect(_titleWordCount, 5); // 5 words

    // Test for _updateSubtitleCounts
    _updateSubtitleCounts('This is the subtitle');
    expect(_subtitleCharCount, 20); // 20 characters
    expect(_subtitleWordCount, 4); // 4 words
    print('This is a test title. Character count for title: $_titleCharCount');
    print('This is a test title. Word count for title: $_titleWordCount');
    print('This is a test title. Character count for subtitle: $_subtitleCharCount');
    print('This is a test title. Word count for subtitle: $_subtitleWordCount');
  });
}
