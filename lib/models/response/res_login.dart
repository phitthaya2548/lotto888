// To parse this JSON data, do
//
//     final responselogin = responseloginFromJson(jsonString);

import 'dart:convert';

Responselogin responseloginFromJson(String str) => Responselogin.fromJson(json.decode(str));

String responseloginToJson(Responselogin data) => json.encode(data.toJson());

class Responselogin {
    String message;
    User user;

    Responselogin({
        required this.message,
        required this.user,
    });

    factory Responselogin.fromJson(Map<String, dynamic> json) => Responselogin(
        message: json["message"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "user": user.toJson(),
    };
}

class User {
    int id;
    String username;
    String fullName;
    String phone;
    String role;

    User({
        required this.id,
        required this.username,
        required this.fullName,
        required this.phone,
        required this.role,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        fullName: json["full_name"],
        phone: json["phone"],
        role: json["role"],
    );


    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "phone": phone,
        "role": role,
    };
}
