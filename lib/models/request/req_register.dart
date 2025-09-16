// To parse this JSON data, do
//
//     final registerResponse = registerResponseFromJson(jsonString);

import 'dart:convert';

RegisterResponse registerResponseFromJson(String str) => RegisterResponse.fromJson(json.decode(str));

String registerResponseToJson(RegisterResponse data) => json.encode(data.toJson());

class RegisterResponse {
    String username;
    String email;
    String password;
    String fullName;
    String phone;
    int money;

    RegisterResponse({
        required this.username,
        required this.email,
        required this.password,
        required this.fullName,
        required this.phone,
        required this.money,
    });

    factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        username: json["username"],
        email: json["email"],
        password: json["password"],
        fullName: json["full_name"],
        phone: json["phone"],
        money: json["money"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "password": password,
        "full_name": fullName,
        "phone": phone,
        "money": money,
    };
}
