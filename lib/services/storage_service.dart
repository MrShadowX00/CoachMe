import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/chat_message.dart';

class StorageService {
  static const _habitsKey = 'habits';
  static const _chatKey = 'chat_history';

  static String getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_habitsKey) ?? [];
    return raw.map((s) => Habit.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = habits.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_habitsKey, raw);
  }

  static Future<Habit> toggleHabitToday(Habit habit) async {
    final today = getTodayString();
    final dates = List<String>.from(habit.completedDates);
    int streak = habit.streak;

    if (dates.contains(today)) {
      dates.remove(today);
      streak = _calculateStreak(dates);
    } else {
      dates.add(today);
      streak = _calculateStreak(dates);
    }

    return habit.copyWith(completedDates: dates, streak: streak);
  }

  static int _calculateStreak(List<String> dates) {
    if (dates.isEmpty) return 0;
    final sorted = List<String>.from(dates)..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime current = DateTime.now();

    for (final dateStr in sorted) {
      final date = DateTime.parse(dateStr);
      final diff = current.difference(date).inDays;
      if (diff <= 1) {
        streak++;
        current = date;
      } else {
        break;
      }
    }
    return streak;
  }

  static Future<List<ChatMessage>> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  static Future<void> saveChatHistory(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(messages.map((m) => m.toJson()).toList());
    await prefs.setString(_chatKey, raw);
  }

  static Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatKey);
  }
}
