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
  late final bool isApprove;
  final String commentByAdmin;
  late final bool isSuspend;
  late final bool isDelete;
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
    required this.isSuspend,
    required this.isDelete, 
    this.averageRating = 0.0,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc,{double averageRating = 0.0}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Debugging: Print entire document data
    print('Restaurant document data: $data');

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
      averageRating: averageRating,
      isSuspend: data['isSuspend'] ?? false,
      isDelete: data['isDelete'] ?? false,
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

    // Function to determine status
  String getStatus() {
    if (isDelete) {
      return "Deleted";
    } else if (isSuspend) {
      return "Suspended";
    } else if (!isApprove && commentByAdmin.isEmpty) {
      return "Pending Approval";
    } else if (!isApprove && commentByAdmin.isNotEmpty) {
      return "Declined";
    } else {
      return "Active";
    }
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
    bool? isApprove,
    String? commentByAdmin,
    bool? isSuspend,
    bool? isDelete,
    double? averageRating,
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
      isApprove: isApprove ?? this.isApprove,
      commentByAdmin: commentByAdmin ?? this.commentByAdmin,
      isSuspend: isSuspend ?? this.isSuspend,
      isDelete: isDelete ?? this.isDelete,
      averageRating: averageRating ?? this.averageRating,
    );
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
