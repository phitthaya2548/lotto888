
import 'dart:convert';

Requestlogin requesttloginFromJson(String str) => Requestlogin.fromJson(json.decode(str));

String requesttloginToJson(Requestlogin data) => json.encode(data.toJson());

class Requestlogin {
    String username;
    String password;

    Requestlogin({
        required this.username,
        required this.password,
    });

    factory Requestlogin.fromJson(Map<String, dynamic> json) => Requestlogin(
        username: json["username"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
    };
}
