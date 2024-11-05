import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/activity.dart';

class Restaurant {
  final String id;
  final String name;
  final GeoPoint location;
  final List<String> cuisineType;
  final List<String> menu;
  final Map<String, OperatingHours> operatingHours;
  final String intro;
  final String image;
  final List<String> tags;
  final bool isApprove;
  final String commentByAdmin;
  double averageRating;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.cuisineType,
    required this.menu,
    required this.operatingHours,
    required this.intro,
    required this.image, // Updated constructor
    required this.tags,
    required this.isApprove,
    required this.commentByAdmin,
    this.averageRating = 0.0,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc,{double averageRating = 0.0}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle cuisineType field
    List<String> cuisineType = [];
    if (data['cuisineType'] is String) {
      cuisineType.add(data['cuisineType']);
    } else if (data['cuisineType'] is List) {
      cuisineType =
          List<String>.from(data['cuisineType'].map((item) => item.toString()));
    }

    // Handle tags field
    List<String> tags = [];
    if (data['tags'] is List) {
      tags = List<String>.from(data['tags'].map((item) => item.toString()));
    }

    // Handle menu field as List<String>
    List<String> menu = [];
    if (data['menu'] is List) {
      menu = List<String>.from(data['menu'].map((item) => item.toString()));
    }

    // Handle operatingHours field
    Map<String, OperatingHours> operatingHours = {};
    if (data['operatingHours'] is Map<String, dynamic>) {
      operatingHours =
          (data['operatingHours'] as Map<String, dynamic>).map((day, hours) {
        if (hours is Map<String, dynamic>) {
          return MapEntry(day, OperatingHours.fromMap(hours));
        }
        return MapEntry(day, OperatingHours(open: '', close: ''));
      });
    }

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'], // Assuming this is already a GeoPoint
      cuisineType: cuisineType,
      menu: menu,
      operatingHours: operatingHours,
      intro: data['intro'] ?? '',
      image: data['image'] ?? '',
      tags: tags,
      isApprove: data['isApprove'] ?? false,
      commentByAdmin: data['commentByAdmin'] ?? '',
      averageRating: averageRating,
    );
  }

  // Method to convert Restaurant instance into a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location, // Ensure this is a GeoPoint
      'cuisineType': cuisineType,
      'menu': menu, // List of Strings for image URLs
      'operatingHours':
          operatingHours.map((day, hours) => MapEntry(day, hours.toMap())),
      'intro': intro,
      'image': image, // Single image URL
      'tags': tags,
      'isApprove': isApprove, // Add isApprove field
      'commentByAdmin': commentByAdmin, // Add commentByAdmin field
    };
  }
}

class OperatingHours {
  String open;
  String close;

  OperatingHours({
    required this.open,
    required this.close,
  });

  // Factory constructor to create OperatingHours from a map
  factory OperatingHours.fromMap(Map<String, dynamic> data) {
    return OperatingHours(
      open: data['open'] ?? '',
      close: data['close'] ?? '',
    );
  }

  // Method to convert OperatingHours instance into a map
  Map<String, dynamic> toMap() {
    return {
      'open': open,
      'close': close,
    };
  }
}
