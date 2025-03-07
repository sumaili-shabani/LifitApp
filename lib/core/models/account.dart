class ModelAccount {
  final List<DatumAccount> data;

  ModelAccount({
    required this.data,
  });

  factory ModelAccount.fromJson(Map<String, dynamic> json) {
    return ModelAccount(
      data: List<DatumAccount>.from(
          json['data'].map((x) => DatumAccount.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DatumAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String password;
  final String sexe;
  final String telephone;
  final String adresse;

  DatumAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.sexe,
    required this.telephone,
    required this.adresse,
  });

  factory DatumAccount.fromJson(Map<String, dynamic> json) {
    return DatumAccount(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      password: json['password'],
      sexe: json['sexe'],
      telephone: json['telephone'],
      adresse: json['adresse'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'password': password,
        'sexe': sexe,
        'telephone': telephone,
        'adresse': adresse,
      };
}
