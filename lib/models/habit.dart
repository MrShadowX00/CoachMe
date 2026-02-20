import 'dart:convert';

class Habit {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final String frequency;
  final List<String> completedDates;
  final String createdAt;
  int streak;

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    this.frequency = 'daily',
    List<String>? completedDates,
    String? createdAt,
    this.streak = 0,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  bool isCompletedOn(String date) => completedDates.contains(date);

  bool get isCompletedToday {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(dateStr);
  }

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    String? category,
    String? frequency,
    List<String>? completedDates,
    String? createdAt,
    int? streak,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      completedDates: completedDates ?? List.from(this.completedDates),
      createdAt: createdAt ?? this.createdAt,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'category': category,
        'frequency': frequency,
        'completedDates': completedDates,
        'createdAt': createdAt,
        'streak': streak,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'],
        category: json['category'] ?? 'health',
        frequency: json['frequency'] ?? 'daily',
        completedDates: List<String>.from(json['completedDates'] ?? []),
        createdAt: json['createdAt'],
        streak: json['streak'] ?? 0,
      );

  String toJsonString() => jsonEncode(toJson());
  factory Habit.fromJsonString(String str) =>
      Habit.fromJson(jsonDecode(str));
}
