import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String status;
  final String commentByAdmin;
  final String email;
  double averageRating;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.cuisineType,
    required this.menu,
    required this.operatingHours,
    required this.intro,
    required this.image,
    required this.tags,
    required this.status,
    required this.commentByAdmin,
    required this.email,
    this.averageRating = 0.0,
  });

  // Factory constructor to create Restaurant from Firestore data
  factory Restaurant.fromFirestore(DocumentSnapshot doc, {double averageRating = 0.0}) {
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

    // Handle operatingHours field as nested map of {day: {open: "", close: ""}}
    Map<String, OperatingHours> operatingHours = {};
    if (data['operatingHours'] is Map<String, dynamic>) {
      operatingHours = (data['operatingHours'] as Map<String, dynamic>).map((day, hoursData) {
        if (hoursData is Map<String, dynamic>) {
          return MapEntry(day, OperatingHours.fromMap(hoursData));
        }
        return MapEntry(day, OperatingHours(openTime: '', closeTime: ''));
      });
    }

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0), // Default to (0,0) if missing
      cuisineType: cuisineType,
      menu: menu,
      operatingHours: operatingHours,
      intro: data['intro'] ?? '',
      image: data['image'] ?? '',
      tags: tags,
      commentByAdmin: data['commentByAdmin'] ?? '',
      email: data['email'] ?? '',
      averageRating: averageRating,
      status: data['status'] ?? 'active',
    );
  }
  

  // Convert Restaurant instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'cuisineType': cuisineType,
      'menu': menu,
      'operatingHours': operatingHours.map((day, hours) => MapEntry(day, hours.toMap())),
      'intro': intro,
      'image': image,
      'tags': tags,
      'email': email,
      'status': status,
      'commentByAdmin': commentByAdmin, // Add commentByAdmin field
    };
  }

Restaurant copyWith({
    String? id,
    String? name,
    GeoPoint? location,
    List<String>? cuisineType,
    List<String>? menu,
    Map<String, OperatingHours>? operatingHours,
    String? intro,
    String? image,
    List<String>? tags,
    String? commentByAdmin,
    String? status,
    double? averageRating,
    String? email,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      cuisineType: cuisineType ?? this.cuisineType,
      menu: menu ?? this.menu,
      operatingHours: operatingHours ?? this.operatingHours,
      intro: intro ?? this.intro,
      image: image ?? this.image,
      tags: tags ?? this.tags,
      commentByAdmin: commentByAdmin ?? this.commentByAdmin,
      status: status ?? this.status,
      averageRating: averageRating ?? this.averageRating,
      email: email ?? this.email,
    );
  }

}

class OperatingHours {
  final String openTime;
  final String closeTime;

  OperatingHours({
    required this.openTime,
    required this.closeTime,
  });

  // Factory constructor to create OperatingHours from a map
  factory OperatingHours.fromMap(Map<String, dynamic> data) {
    return OperatingHours(
      openTime: data['open'] ?? '',
      closeTime: data['close'] ?? '',
    );
  }

  // Getters for open and close times
  String get open => openTime;
  String get close => closeTime;

  // Method to convert OperatingHours instance into a map
  Map<String, dynamic> toMap() {
    return {
      'open': openTime,
      'close': closeTime,
    };
  }
}


