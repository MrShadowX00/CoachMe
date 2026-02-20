import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/ads_service_stub.dart'
    if (dart.library.io) '../services/ads_service_mobile.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/habit_tile.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Habit> _habits = [];
  final _gemini = GeminiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final habits = await StorageService.getHabits();
    setState(() => _habits = habits);
  }

  Future<void> _delete(Habit habit) async {
    _habits.removeWhere((h) => h.id == habit.id);
    await StorageService.saveHabits(_habits);
    setState(() {});
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddHabitSheet(
        gemini: _gemini,
        onAdd: (habit) async {
          _habits.add(habit);
          await StorageService.saveHabits(_habits);
          setState(() {});
          // Show interstitial every 3 habits added
          if (_habits.length % 3 == 0) {
            AdsService.showInterstitial();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: _habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 64)),
                  const Gap(16),
                  Text(
                    'No habits yet',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Tap + to add your first habit',
                    style: GoogleFonts.inter(color: AppTheme.muted),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: _habits
                  .map((h) => HabitTile(
                        habit: h,
                        onToggle: () {},
                        showStreak: true,
                        onDelete: () => _delete(h),
                      ))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddModal,
        backgroundColor: AppTheme.primary,
        label: Text('Add Habit', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  final GeminiService gemini;
  final Function(Habit) onAdd;

  const _AddHabitSheet({required this.gemini, required this.onAdd});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _nameCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  String _emoji = '💪';
  String _category = 'health';
  bool _loadingSuggestions = false;
  List<Map<String, String>> _suggestions = [];

  final _emojis = ['💪', '🧘', '📚', '💧', '🏃', '🌙', '🎯', '✍️', '🥗', '😴'];
  final _categories = ['health', 'productivity', 'mindfulness', 'fitness', 'learning', 'social'];

  Future<void> _getSuggestions() async {
    if (_goalCtrl.text.trim().isEmpty) return;
    setState(() => _loadingSuggestions = true);
    final suggestions = await widget.gemini.getHabitSuggestions(_goalCtrl.text);
    setState(() {
      _suggestions = suggestions;
      _loadingSuggestions = false;
    });
  }

  void _applySuggestion(Map<String, String> s) {
    setState(() {
      _nameCtrl.text = s['name'] ?? '';
      _emoji = s['emoji'] ?? '💪';
      _category = s['category'] ?? 'health';
    });
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final habit = Habit(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      emoji: _emoji,
      category: _category,
    );
    widget.onAdd(habit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(20),
            Text('New Habit', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textColor)),
            const Gap(20),

            // Goal input for AI suggestions
            TextField(
              controller: _goalCtrl,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(
                hintText: 'Your goal (e.g. "lose weight")',
                hintStyle: const TextStyle(color: AppTheme.muted),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                suffixIcon: _loadingSuggestions
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)))
                    : IconButton(icon: const Icon(Icons.auto_awesome, color: AppTheme.secondary), onPressed: _getSuggestions),
              ),
            ),

            if (_suggestions.isNotEmpty) ...[
              const Gap(12),
              Text('AI Suggestions:', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.muted)),
              const Gap(8),
              ..._suggestions.map((s) => GestureDetector(
                onTap: () => _applySuggestion(s),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Text(s['emoji'] ?? '✨', style: const TextStyle(fontSize: 20)),
                      const Gap(10),
                      Text(s['name'] ?? '', style: GoogleFonts.inter(color: AppTheme.textColor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              )),
            ],

            const Gap(16),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(
                hintText: 'Habit name',
                hintStyle: const TextStyle(color: AppTheme.muted),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
              ),
            ),
            const Gap(16),

            Text('Emoji', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.muted, fontWeight: FontWeight.w600)),
            const Gap(8),
            Wrap(
              spacing: 10,
              children: _emojis.map((e) => GestureDetector(
                onTap: () => setState(() => _emoji = e),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _emoji == e ? AppTheme.primary.withOpacity(0.2) : AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _emoji == e ? AppTheme.primary : AppTheme.cardBorder),
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 22)),
                ),
              )).toList(),
            ),
            const Gap(16),

            Text('Category', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.muted, fontWeight: FontWeight.w600)),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) => GestureDetector(
                onTap: () => setState(() => _category = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _category == c ? AppTheme.primary : AppTheme.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _category == c ? AppTheme.primary : AppTheme.cardBorder),
                  ),
                  child: Text(c, style: GoogleFonts.inter(fontSize: 13, color: _category == c ? Colors.white : AppTheme.muted, fontWeight: FontWeight.w500)),
                ),
              )).toList(),
            ),
            const Gap(24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Add Habit', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
