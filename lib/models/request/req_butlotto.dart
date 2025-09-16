// To parse this JSON data, do
//
//     final requestBuylotto = requestBuylottoFromJson(jsonString);

import 'dart:convert';

RequestBuylotto requestBuylottoFromJson(String str) => RequestBuylotto.fromJson(json.decode(str));

String requestBuylottoToJson(RequestBuylotto data) => json.encode(data.toJson());

class RequestBuylotto {
    int drawId;
    int userId;
    String number;
    int price;

    RequestBuylotto({
        required this.drawId,
        required this.userId,
        required this.number,
        required this.price,
    });

    factory RequestBuylotto.fromJson(Map<String, dynamic> json) => RequestBuylotto(
        drawId: json["drawId"],
        userId: json["userId"],
        number: json["number"],
        price: json["price"],
    );

    Map<String, dynamic> toJson() => {
        "drawId": drawId,
        "userId": userId,
        "number": number,
        "price": price,
    };
}
