// res_lotto.dart
import 'dart:convert';

ResponseRandomLotto responseRandomLottoFromJson(String str) =>
    ResponseRandomLotto.fromJson(json.decode(str) as Map<String, dynamic>);

String responseRandomLottoToJson(ResponseRandomLotto data) =>
    json.encode(data.toJson());

// ===== helpers: parse ปลอดภัย =====
int _toInt(Object? v, {int def = 0}) {
  if (v == null) return def;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? def;
  return def;
}

String _toStr(Object? v, {String def = ''}) => v?.toString() ?? def;

DateTime _toDate(Object? v) =>
    DateTime.tryParse(_toStr(v)) ?? DateTime.fromMillisecondsSinceEpoch(0);

// ===== models =====
class ResponseRandomLotto {
  final bool success;
  final DrawPayload draw;

  ResponseRandomLotto({
    required this.success,
    required this.draw,
  });

  factory ResponseRandomLotto.fromJson(Map<String, dynamic> json) {
    return ResponseRandomLotto(
      success: json['success'] == true,
      draw: DrawPayload.fromJson(
        (json['draw'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'draw': draw.toJson(),
      };
}

class DrawPayload {
  final int drawNumber;
  final DateTime drawDate;
  final Results results;
  final Amounts amounts;

  DrawPayload({
    required this.drawNumber,
    required this.drawDate,
    required this.results,
    required this.amounts,
  });

  factory DrawPayload.fromJson(Map<String, dynamic> json) => DrawPayload(
        drawNumber: _toInt(json['drawNumber']),
        drawDate: _toDate(json['drawDate']),
        results: Results.fromJson(
          (json['results'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        amounts: Amounts.fromJson(
          (json['amounts'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );

  Map<String, dynamic> toJson() => {
        'drawNumber': drawNumber,
        'drawDate':
            '${drawDate.year.toString().padLeft(4, '0')}-${drawDate.month.toString().padLeft(2, '0')}-${drawDate.day.toString().padLeft(2, '0')}',
        'results': results.toJson(),
        'amounts': amounts.toJson(),
      };
}

class Results {
  final String first;
  final String second;
  final String third;
  final String last3;
  final String last2;

  Results({
    required this.first,
    required this.second,
    required this.third,
    required this.last3,
    required this.last2,
  });

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        first: _toStr(json['first']),
        second: _toStr(json['second']),
        third: _toStr(json['third']),
        last3: _toStr(json['last3']),
        last2: _toStr(json['last2']),
      );

  Map<String, dynamic> toJson() => {
        'first': first,
        'second': second,
        'third': third,
        'last3': last3,
        'last2': last2,
      };
}

class Amounts {
  final int prize1Amount;
  final int prize2Amount;
  final int prize3Amount;
  final int last3Amount;
  final int last2Amount;

  Amounts({
    required this.prize1Amount,
    required this.prize2Amount,
    required this.prize3Amount,
    required this.last3Amount,
    required this.last2Amount,
  });

  factory Amounts.fromJson(Map<String, dynamic> json) => Amounts(
        prize1Amount: _toInt(json['prize1Amount']),
        prize2Amount: _toInt(json['prize2Amount']),
        prize3Amount: _toInt(json['prize3Amount']),
        last3Amount: _toInt(json['last3Amount']),
        last2Amount: _toInt(json['last2Amount']),
      );

  Map<String, dynamic> toJson() => {
        'prize1Amount': prize1Amount,
        'prize2Amount': prize2Amount,
        'prize3Amount': prize3Amount,
        'last3Amount': last3Amount,
        'last2Amount': last2Amount,
      };
}
