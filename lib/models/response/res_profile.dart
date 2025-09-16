// To parse this JSON data, do
//
//     final responseRandomProfile = responseRandomProfileFromJson(jsonString);

import 'dart:convert';

ResponseRandomProfile responseRandomProfileFromJson(String str) => ResponseRandomProfile.fromJson(json.decode(str));

String responseRandomProfileToJson(ResponseRandomProfile data) => json.encode(data.toJson());

class ResponseRandomProfile {
    bool success;
    User user;
    Wallet wallet;
    Tickets tickets;

    ResponseRandomProfile({
        required this.success,
        required this.user,
        required this.wallet,
        required this.tickets,
    });

    factory ResponseRandomProfile.fromJson(Map<String, dynamic> json) => ResponseRandomProfile(
        success: json["success"],
        user: User.fromJson(json["user"]),
        wallet: Wallet.fromJson(json["wallet"]),
        tickets: Tickets.fromJson(json["tickets"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "user": user.toJson(),
        "wallet": wallet.toJson(),
        "tickets": tickets.toJson(),
    };
}

class Tickets {
    int total;

    Tickets({
        required this.total,
    });

    factory Tickets.fromJson(Map<String, dynamic> json) => Tickets(
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
    };
}

class User {
    int id;
    String username;
    String fullName;
    String email;
    String phone;
    String role;
    DateTime createdAt;

    User({
        required this.id,
        required this.username,
        required this.fullName,
        required this.email,
        required this.phone,
        required this.role,
        required this.createdAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        fullName: json["full_name"],
        email: json["email"],
        phone: json["phone"],
        role: json["role"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "role": role,
        "created_at": createdAt.toIso8601String(),
    };
}

class Wallet {
    int balance;

    Wallet({
        required this.balance,
    });

    factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        balance: json["balance"],
    );

    Map<String, dynamic> toJson() => {
        "balance": balance,
    };
}
