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
