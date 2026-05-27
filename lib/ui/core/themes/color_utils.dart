import 'package:flutter/material.dart';

Color getDeadlineColor(DateTime? deadline) {
  if (deadline == null) return Colors.grey.shade400; // Sem prazo definido

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final limit = DateTime(deadline.year, deadline.month, deadline.day);

  final daysLeft = limit.difference(today).inDays;

  // Projeto vencido ou vence hoje
  if (daysLeft <= 0) return Colors.red;

  // Prazo muito distante
  if (daysLeft >= 120) return Colors.blue.shade700;

  // Transição gradual suave calculada entre os dias restantes
  if (daysLeft <= 15) {
    return Color.lerp(Colors.red, Colors.orange, daysLeft / 15)!;
  } else if (daysLeft <= 30) {
    return Color.lerp(
        Colors.orange, Colors.yellow.shade700, (daysLeft - 15) / 15)!;
  } else if (daysLeft <= 60) {
    return Color.lerp(
        Colors.yellow.shade700, Colors.green, (daysLeft - 30) / 30)!;
  } else if (daysLeft <= 90) {
    return Color.lerp(Colors.green, Colors.lightBlue, (daysLeft - 60) / 30)!;
  } else {
    return Color.lerp(
        Colors.lightBlue, Colors.blue.shade700, (daysLeft - 90) / 30)!;
  }
}
