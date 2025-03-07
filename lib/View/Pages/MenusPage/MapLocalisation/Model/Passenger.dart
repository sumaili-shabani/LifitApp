class Passenger {
  final int id;
  final String name;
  final String phone;
  final String image;
  final String idDemande;
  final String dateDemande; // Nouvelle propriété pour la date de demande
  final double latitude;
  final double longitude;

  Passenger({
    required this.id,
    required this.name,
    required this.phone,
    required this.image,
    required this.idDemande,
    required this.dateDemande, // Initialisation de la date de demande
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'image': image,
      'idDemande': idDemande,
      'dateDemande': dateDemande, // Ajouter la date de demande
      'location': {'latitude': latitude, 'longitude': longitude},
    };
  }

  static Passenger fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      image: json['image'],
      idDemande: json['idDemande'],
      dateDemande: json['dateDemande'], // Récupérer la date de demande
      latitude: json['location']['latitude'],
      longitude: json['location']['longitude'],
    );
  }
}
