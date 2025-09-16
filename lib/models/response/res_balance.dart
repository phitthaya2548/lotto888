
// To parse this JSON data, do
//
//     final responseRandomBalance = responseRandomBalanceFromJson(jsonString);

import 'dart:convert';

ResponseRandomBalance responseRandomBalanceFromJson(String str) => ResponseRandomBalance.fromJson(json.decode(str));

String responseRandomBalanceToJson(ResponseRandomBalance data) => json.encode(data.toJson());

class ResponseRandomBalance {
    bool success;
    Wallet wallet;

    ResponseRandomBalance({
        required this.success,
        required this.wallet,
    });

    factory ResponseRandomBalance.fromJson(Map<String, dynamic> json) => ResponseRandomBalance(
        success: json["success"],
        wallet: Wallet.fromJson(json["wallet"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "wallet": wallet.toJson(),
    };
}

class Wallet {
    int id;
    int balance;

    Wallet({
        required this.id,
        required this.balance,
    });

    factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json["id"],
        balance: json["balance"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "balance": balance,
    };
}
