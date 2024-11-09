class Complain {
  final String id;
  final String? name;
  final String description;
  String feedback;
  final String userType;
  final String userID;

  Complain({
    required this.id,
    this.name,
    required this.description,
    required this.feedback,
    required this.userType,
    required this.userID,
  });

  factory Complain.fromMap(Map<String, dynamic> data, String id, String userID, String userType, String name) {
    return Complain(
      id: id,
      description: data['description'],
      feedback: data['feedback'] ?? '',
      name: name,
      userType: userType,
      userID: userID, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'feedback': feedback,
    };
  }
}
