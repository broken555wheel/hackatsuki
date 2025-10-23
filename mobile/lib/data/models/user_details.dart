class UserDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String city;

  const UserDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.city
  });

  factory UserDetails.empty() {
    return UserDetails(firstName: "", lastName: "", email: "", phoneNumber: "", city: "");
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phoneNumber": phoneNumber,
      "city" : city
    };
  }

  UserDetails copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? city
  }) {
    return UserDetails(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city
    );
  }
}
