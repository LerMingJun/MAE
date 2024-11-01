import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/models/activity.dart';

class Restaurant {
  String id;
  String name;
  GeoPoint location;
  List<String> cuisineType;
  Map<String, List<String>> menu;
  Map<String, OperatingHours> operatingHours;
  String intro;
  String image;
  List<String> tags;
  bool isApprove;
  String commentByAdmin;

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
  });
  
  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Debugging: Print entire document data
    print('Restaurant document data: $data');

    // Handle the cuisineType field
    List<String> cuisineType = [];
    if (data['cuisineType'] is String) {
      cuisineType.add(data['cuisineType']);
    } else if (data['cuisineType'] is List<dynamic>) {
      cuisineType = List<String>.from(data['cuisineType'].map((item) {
        print('Cuisine type item: $item'); // Debugging
        return item.toString();
      }));
    }

    // Handle tags
    List<String> tags = [];
    if (data['tags'] is List<dynamic>) {
      tags = List<String>.from(data['tags'].map((item) {
        print('Tag item: $item'); // Debugging
        return item.toString();
      }));
    }

    // Handle menu
    Map<String, List<String>> menu = {};
    if (data['menu'] is Map<String, dynamic>) {
      menu = (data['menu'] as Map<String, dynamic>).map((key, value) {
        // Ensure each list is of type List<String>
        if (value is List<dynamic>) {
          return MapEntry(
              key, List<String>.from(value.map((item) => item.toString())));
        }
        return MapEntry(key, []);
      });
    }

    // Handle operatingHours
    Map<String, OperatingHours> operatingHours = {};
    if (data['operatingHours'] is Map<String, dynamic>) {
      operatingHours =
          (data['operatingHours'] as Map<String, dynamic>).map((day, hours) {
        return MapEntry(
          day,
          OperatingHours.fromMap(hours),
        );
      });
    }

    // Debugging: Check final values before creating Restaurant
    print('Final cuisineType: $cuisineType');
    print('Final tags: $tags');
    print('Final menu: $menu');
    print('Final operating hours: $operatingHours');

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
    );
  }

  // Method to convert Restaurant instance into a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'cuisineType': cuisineType,
      'menu': menu,
      'operatingHours':
          operatingHours.map((day, hours) => MapEntry(day, hours.toMap())),
      'intro': intro,
      'image': image, // Updated to save a single image
      'tags': tags,
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
