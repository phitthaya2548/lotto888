// To parse this JSON data, do
//
//     final responseRandomLesson = responseRandomLessonFromJson(jsonString);

import 'dart:convert';

ResponseRandomLesson responseRandomLessonFromJson(String str) => ResponseRandomLesson.fromJson(json.decode(str));

String responseRandomLessonToJson(ResponseRandomLesson data) => json.encode(data.toJson());

class ResponseRandomLesson {
    bool success;
    List<Draw> draws;

    ResponseRandomLesson({
        required this.success,
        required this.draws,
    });

    factory ResponseRandomLesson.fromJson(Map<String, dynamic> json) => ResponseRandomLesson(
        success: json["success"],
        draws: List<Draw>.from(json["draws"].map((x) => Draw.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "draws": List<dynamic>.from(draws.map((x) => x.toJson())),
    };
}

class Draw {
    int drawNumber;
    DateTime drawDate;

    Draw({
        required this.drawNumber,
        required this.drawDate,
    });

    factory Draw.fromJson(Map<String, dynamic> json) => Draw(
        drawNumber: json["drawNumber"],
        drawDate: DateTime.parse(json["drawDate"]),
    );

    Map<String, dynamic> toJson() => {
        "drawNumber": drawNumber,
        "drawDate": "${drawDate.year.toString().padLeft(4, '0')}-${drawDate.month.toString().padLeft(2, '0')}-${drawDate.day.toString().padLeft(2, '0')}",
    };
}
