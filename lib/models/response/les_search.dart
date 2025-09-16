// To parse this JSON data, do
//
//     final responseRandomSearch = responseRandomSearchFromJson(jsonString);

import 'dart:convert';

ResponseRandomSearch responseRandomSearchFromJson(String str) => ResponseRandomSearch.fromJson(json.decode(str));

String responseRandomSearchToJson(ResponseRandomSearch data) => json.encode(data.toJson());

class ResponseRandomSearch {
    bool success;
    int drawId;
    String ticketNumber;
    bool canBuy;
    String currentStatus;

    ResponseRandomSearch({
        required this.success,
        required this.drawId,
        required this.ticketNumber,
        required this.canBuy,
        required this.currentStatus,
    });

    factory ResponseRandomSearch.fromJson(Map<String, dynamic> json) => ResponseRandomSearch(
        success: json["success"],
        drawId: json["drawId"],
        ticketNumber: json["ticketNumber"],
        canBuy: json["canBuy"],
        currentStatus: json["currentStatus"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "drawId": drawId,
        "ticketNumber": ticketNumber,
        "canBuy": canBuy,
        "currentStatus": currentStatus,
    };
}
