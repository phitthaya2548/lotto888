// To parse this JSON data, do
//
//     final requestRandomLotto = requestRandomLottoFromJson(jsonString);

import 'dart:convert';

RequestRandomLotto requestRandomLottoFromJson(String str) => RequestRandomLotto.fromJson(json.decode(str));

String requestRandomLottoToJson(RequestRandomLotto data) => json.encode(data.toJson());

class RequestRandomLotto {
    String sourceMode;
    bool? uniqueExact;
    int prize1Amount;
    int prize2Amount;
    int prize3Amount;
    int last3Amount;
    int last2Amount;

    RequestRandomLotto({
        required this.sourceMode,
        required this.uniqueExact,
        required this.prize1Amount,
        required this.prize2Amount,
        required this.prize3Amount,
        required this.last3Amount,
        required this.last2Amount,
    });

    factory RequestRandomLotto.fromJson(Map<String, dynamic> json) => RequestRandomLotto(
        sourceMode: json["source_mode"],
        uniqueExact: json["unique_exact"],
        prize1Amount: json["prize1_amount"],
        prize2Amount: json["prize2_amount"],
        prize3Amount: json["prize3_amount"],
        last3Amount: json["last3_amount"],
        last2Amount: json["last2_amount"],
    );

    Map<String, dynamic> toJson() => {
        "source_mode": sourceMode,
        "unique_exact": uniqueExact,
        "prize1_amount": prize1Amount,
        "prize2_amount": prize2Amount,
        "prize3_amount": prize3Amount,
        "last3_amount": last3Amount,
        "last2_amount": last2Amount,
    };
}
