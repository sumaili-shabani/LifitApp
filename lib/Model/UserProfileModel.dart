class UserProfilModel {
  final String? name;
  final String? email;
  final String? phone;
  final String? city;

  UserProfilModel({
     this.name,
     this.email,
     this.phone,
     this.city,
  });

  factory UserProfilModel.fromJson(Map<String, dynamic> json) {
    return UserProfilModel(
      name: json['name'],
      email: json['email'],
      phone: json['telephone'],
      city: json['adresse'],
    );
  }
}
