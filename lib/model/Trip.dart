class VoyageModel {
  final int? voyageId;
  final int? conducteurId;
  final String depart;
  final String destination;
  final DateTime timestamp;
  final int placeDisponible;

  VoyageModel({
    this.voyageId,
    required this.conducteurId,
    required this.depart,
    required this.destination,
    required this.timestamp,
    required this.placeDisponible,
  });

  Map<String, dynamic> toJson() => {
    'voyageId': voyageId,
    'conducteurId': conducteurId,
    'Depart': depart,
    'Destination': destination,
    'Timestamp': timestamp.toIso8601String(),
    'placeDisponible': placeDisponible,
  };

  factory VoyageModel.fromJson(Map<String, dynamic> json) {
    return VoyageModel(
      voyageId: json['voyageId'] as int?, // Si c'est acceptable que voyageId soit nul
      conducteurId: json['conducteurId'] as int? ?? 0, // Fournit une valeur par défaut si null
      depart: json['Depart'] as String? ?? 'Départ inconnu', // Fournit une valeur par défaut si null
      destination: json['Destination'] as String? ?? 'Destination inconnue', // Fournit une valeur par défaut si null
      timestamp: DateTime.parse(json['timestamp'] as String), // Assurez-vous que timestamp ne soit jamais nul
      placeDisponible: json['placeDisponible'] as int,
    );
  }

}