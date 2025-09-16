// To parse this JSON data, do
//
//     final responseRandomLotto = responseRandomLottoFromJson(jsonString);

import 'dart:convert';

ResponseRandomLotto responseRandomLottoFromJson(String str) => ResponseRandomLotto.fromJson(json.decode(str));

String responseRandomLottoToJson(ResponseRandomLotto data) => json.encode(data.toJson());

class ResponseRandomLotto {
    bool success;
    Draw draw;

    ResponseRandomLotto({
        required this.success,
        required this.draw,
    });

    factory ResponseRandomLotto.fromJson(Map<String, dynamic> json) => ResponseRandomLotto(
        success: json["success"],
        draw: Draw.fromJson(json["draw"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "draw": draw.toJson(),
    };
}

class Draw {
    int id;
    int drawNumber;
    DateTime drawDate;
    String status;
    Results results;
    Amounts amounts;
    Meta meta;

    Draw({
        required this.id,
        required this.drawNumber,
        required this.drawDate,
        required this.status,
        required this.results,
        required this.amounts,
        required this.meta,
    });

    factory Draw.fromJson(Map<String, dynamic> json) => Draw(
        id: json["id"],
        drawNumber: json["drawNumber"],
        drawDate: DateTime.parse(json["drawDate"]),
        status: json["status"],
        results: Results.fromJson(json["results"]),
        amounts: Amounts.fromJson(json["amounts"]),
        meta: Meta.fromJson(json["meta"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "drawNumber": drawNumber,
        "drawDate": drawDate.toIso8601String(),
        "status": status,
        "results": results.toJson(),
        "amounts": amounts.toJson(),
        "meta": meta.toJson(),
    };
}

class Amounts {
    int prize1Amount;
    int prize2Amount;
    int prize3Amount;
    int last3Amount;
    int last2Amount;

    Amounts({
        required this.prize1Amount,
        required this.prize2Amount,
        required this.prize3Amount,
        required this.last3Amount,
        required this.last2Amount,
    });

    factory Amounts.fromJson(Map<String, dynamic> json) => Amounts(
        prize1Amount: json["prize1Amount"],
        prize2Amount: json["prize2Amount"],
        prize3Amount: json["prize3Amount"],
        last3Amount: json["last3Amount"],
        last2Amount: json["last2Amount"],
    );

    Map<String, dynamic> toJson() => {
        "prize1Amount": prize1Amount,
        "prize2Amount": prize2Amount,
        "prize3Amount": prize3Amount,
        "last3Amount": last3Amount,
        "last2Amount": last2Amount,
    };
}

class Meta {
    String sourceMode;

    Meta({
        required this.sourceMode,
    });

    factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        sourceMode: json["sourceMode"],
    );

    Map<String, dynamic> toJson() => {
        "sourceMode": sourceMode,
    };
}

class Results {
    String first;
    String second;
    String third;
    String last3;
    String last2;

    Results({
        required this.first,
        required this.second,
        required this.third,
        required this.last3,
        required this.last2,
    });

    factory Results.fromJson(Map<String, dynamic> json) => Results(
        first: json["first"],
        second: json["second"],
        third: json["third"],
        last3: json["last3"],
        last2: json["last2"],
    );

    Map<String, dynamic> toJson() => {
        "first": first,
        "second": second,
        "third": third,
        "last3": last3,
        "last2": last2,
    };
}
