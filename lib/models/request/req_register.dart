import 'dart:convert';


class RegisterRequest {
  String username;
  String email;
  String password;
  String? fullName;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "password": password,
        if (fullName != null) "full_name": fullName,
      };
}

String registerRequestToJson(RegisterRequest data) =>
    json.encode(data.toJson());

RegisterResponse registerResponseFromJson(String str) =>
    RegisterResponse.fromJson(json.decode(str));

class RegisterResponse {
  bool success;
  String message;
  User user;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        success: json["success"],
        message: json["message"],
        user: User.fromJson(json["user"]),
      );
}

class User {
  int id;
  String username;
  String email;
  String? fullName;
  String? phone;
  String role;


  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.phone,
    required this.role,

  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        fullName: json["full_name"],
        phone: json["phone"],
        role: json["role"],

      );
}
