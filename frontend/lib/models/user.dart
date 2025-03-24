// lib/models/user.dart
class User {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final bool isAdmin;
  final String street;
  final String apartment;
  final String zip;
  final String city;
  final String country;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.isAdmin = false,
    required this.street,
    required this.apartment,
    required this.zip,
    required this.city,
    required this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      street: json['street'] ?? '',
      apartment: json['apartment'] ?? '',
      zip: json['zip'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'isAdmin': isAdmin,
      'street': street,
      'apartment': apartment,
      'zip': zip,
      'city': city,
      'country': country,
    };
  }

  Map<String, dynamic> toRegisterJson(String password) {
    final Map<String, dynamic> data = toJson();
    data['password'] = password;
    return data;
  }

  Map<String, dynamic> toUpdateJson({String? password}) {
    final Map<String, dynamic> data = toJson();
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    return data;
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? isAdmin,
    String? street,
    String? apartment,
    String? zip,
    String? city,
    String? country,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isAdmin: isAdmin ?? this.isAdmin,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      zip: zip ?? this.zip,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}
