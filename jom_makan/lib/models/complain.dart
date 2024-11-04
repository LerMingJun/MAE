class Complain {
  final String id;
  final String? title;
  final String? description;
  final String? feedback;
  final String userType;
  final String? userName; // New field for user or restaurant name

  Complain({
    required this.id,
    this.title,
    this.description,
    this.feedback,
    required this.userType,
    this.userName,
  });

  factory Complain.fromMap(Map<String, dynamic> data, String id, String userType, String? userName) {
    return Complain(
      id: id,
      title: data['title'] as String?,
      description: data['description'] as String?,
      feedback: data['feedback'] as String?,
      userType: userType,
      userName: userName,
    );
  }
}
