import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/habit.dart';
import '../models/chat_message.dart';

class GeminiService {
  static const _apiKey = 'AIzaSyCblsJzehe_0zvhq4q-Qh9ILK3CLzkgC-U';
  static const _systemPrompt =
      'You are CoachMe, a friendly and motivational AI habit coach. '
      'Be concise, encouraging, and personalized. Use emojis naturally. '
      'Keep responses short (2-4 sentences max) unless the user asks for detail.';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text(_systemPrompt),
    );
  }

  Future<String> getDailyMotivation(List<Habit> habits) async {
    try {
      final completedToday =
          habits.where((h) => h.isCompletedToday).length;
      final total = habits.length;
      final bestStreak =
          habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

      final prompt =
          'Give me a short, energetic morning motivation message. '
          'I have $total habits, completed $completedToday today, '
          'and my best streak is $bestStreak days. Make it personal and punchy!';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'You got this today! Keep building those habits! 💪';
    } catch (e) {
      return 'Every day is a new opportunity to grow. Start strong today! 🌟';
    }
  }

  Future<List<Map<String, String>>> getHabitSuggestions(String goal) async {
    try {
      final prompt =
          'Suggest 3 specific daily habits for someone who wants to: "$goal". '
          'For each habit, give: name (short), emoji, category (health/productivity/mindfulness/fitness/learning/social). '
          'Format each as: NAME|EMOJI|CATEGORY. One per line. Nothing else.';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final lines = text.trim().split('\n').where((l) => l.contains('|')).toList();

      return lines.take(3).map((line) {
        final parts = line.split('|');
        return {
          'name': parts[0].trim(),
          'emoji': parts.length > 1 ? parts[1].trim() : '✨',
          'category': parts.length > 2 ? parts[2].trim().toLowerCase() : 'health',
        };
      }).toList();
    } catch (e) {
      return [
        {'name': 'Morning workout', 'emoji': '💪', 'category': 'fitness'},
        {'name': 'Read 10 pages', 'emoji': '📚', 'category': 'learning'},
        {'name': 'Meditate 5 min', 'emoji': '🧘', 'category': 'mindfulness'},
      ];
    }
  }

  Future<String> chatWithCoach(
      List<ChatMessage> history, String userMessage) async {
    try {
      final chat = _model.startChat(
        history: history
            .map((m) => Content(
                  m.isUser ? 'user' : 'model',
                  [TextPart(m.content)],
                ))
            .toList(),
      );

      final response = await chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'I\'m here to help! Tell me more. 😊';
    } catch (e) {
      return 'Sorry, I\'m having trouble connecting right now. Try again! 🙏';
    }
  }

  Future<String> analyzeProgress(List<Habit> habits) async {
    try {
      if (habits.isEmpty) {
        return 'Add your first habit to get personalized insights! 🌱';
      }

      final habitSummary = habits.map((h) {
        final completed = h.completedDates.length;
        return '${h.name}: ${h.streak} day streak, $completed total completions';
      }).join('; ');

      final prompt =
          'Analyze this habit progress and give 2-3 short, specific insights: $habitSummary. '
          'Be encouraging but honest. Suggest one improvement.';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Keep going! Consistency is the key to success. 🔑';
    } catch (e) {
      return 'Great effort this week! Keep your streaks alive and you\'ll see results soon. 💫';
    }
  }
}
