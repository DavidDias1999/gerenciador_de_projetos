import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}

@JsonSerializable()
class Task {
  String id;
  String title;
  bool isCompleted;
  int orderIndex;
  String? completedByUsername;

  @TimestampConverter()
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.orderIndex,
    this.completedByUsername,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
