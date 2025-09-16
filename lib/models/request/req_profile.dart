// To parse this JSON data, do
//
//     final RequestProfileUpdate = RequestProfileUpdateFromJson(jsonString);

import 'dart:convert';

RequestProfileUpdate RequestProfileUpdateFromJson(String str) => RequestProfileUpdate.fromJson(json.decode(str));

String RequestProfileUpdateToJson(RequestProfileUpdate data) => json.encode(data.toJson());

class RequestProfileUpdate {
    String fullName;
    String email;
    String phone;

    RequestProfileUpdate({
        required this.fullName,
        required this.email,
        required this.phone,
    });

    factory RequestProfileUpdate.fromJson(Map<String, dynamic> json) => RequestProfileUpdate(
        fullName: json["full_name"],
        email: json["email"],
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "email": email,
        "phone": phone,
    };
}
