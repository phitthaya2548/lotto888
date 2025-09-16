// To parse this JSON data, do
//
//     final responseRandomListBalance = responseRandomListBalanceFromJson(jsonString);

import 'dart:convert';

ResponseRandomListBalance responseRandomListBalanceFromJson(String str) => ResponseRandomListBalance.fromJson(json.decode(str));

String responseRandomListBalanceToJson(ResponseRandomListBalance data) => json.encode(data.toJson());

class ResponseRandomListBalance {
    bool success;
    List<Item> items;

    ResponseRandomListBalance({
        required this.success,
        required this.items,
    });

    factory ResponseRandomListBalance.fromJson(Map<String, dynamic> json) => ResponseRandomListBalance(
        success: json["success"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class Item {
    int id;
    String txType;
    String amount;
    String refType;
    int refId;
    String note;
    DateTime createdAt;

    Item({
        required this.id,
        required this.txType,
        required this.amount,
        required this.refType,
        required this.refId,
        required this.note,
        required this.createdAt,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        txType: json["tx_type"],
        amount: json["amount"],
        refType: json["ref_type"],
        refId: json["ref_id"],
        note: json["note"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "tx_type": txType,
        "amount": amount,
        "ref_type": refType,
        "ref_id": refId,
        "note": note,
        "created_at": createdAt.toIso8601String(),
    };
}
