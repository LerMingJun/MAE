class Complain {
  final String id;
  final String? name;
  final String? description;
  final String? feedback;
  final String userType;
  final String? restaurantID;

  Complain({
    required this.id,
    this.name,
    this.description,
    this.feedback,
    required this.userType,
    this.restaurantID,
  });

  factory Complain.fromMap(Map<String, dynamic> data, String id, String restaurantID, String userType, String name) {
    return Complain(
      id: id,
      description: data['description'] as String?,
      feedback: data['feedback'] as String?,
      name: name,
      userType: userType,
      restaurantID: restaurantID, 
    );
  }
}
