class Request {
  final int? userId;
  final double originLat;
  final double originLong;
  final double destinationLat;
  final double destinationLong;
  final DateTime time;
  final String status;
  final String type; // Add the 'type' property
  final int seats; // Add the 'seats' property

  Request({
    required this.userId,
    required this.originLat,
    required this.originLong,
    required this.destinationLat,
    required this.destinationLong,
    required this.time,
    required this.status,
    required this.type, // Initialize the 'type' property
    required this.seats, // Initialize the 'seats' property
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'originLat': originLat,
      'originLong': originLong,
      'destinationLat': destinationLat,
      'destinationLong': destinationLong,
      'time': time.toIso8601String(),
      'status': status,
      'type': type,
      'seats': seats, // Serialize the 'seats' property
    };
  }

  // Add factory method to deserialize JSON
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      userId: json['userId'],
      originLat: json['originLat'],
      originLong: json['originLong'],
      destinationLat: json['destinationLat'],
      destinationLong: json['destinationLong'],
      time: DateTime.parse(json['time']),
      status: json['status'],
      type: json['type'], // Deserialize the 'type' property
      seats: json['seats'], // Deserialize the 'seats' property
    );
  }
}