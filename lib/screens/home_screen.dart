import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_tile.dart';
import '../widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  String _motivation = '';
  bool _loadingMotivation = true;
  final _gemini = GeminiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final habits = await StorageService.getHabits();
    setState(() => _habits = habits);
    final motivation = await _gemini.getDailyMotivation(habits);
    setState(() {
      _motivation = motivation;
      _loadingMotivation = false;
    });
  }

  Future<void> _toggle(Habit habit) async {
    final updated = await StorageService.toggleHabitToday(habit);
    final habits = await StorageService.getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) habits[index] = updated;
    await StorageService.saveHabits(habits);
    setState(() => _habits = habits);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int get _completedCount =>
      _habits.where((h) => h.isCompletedToday).length;

  double get _completionRate =>
      _habits.isEmpty ? 0 : _completedCount / _habits.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        backgroundColor: AppTheme.card,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              backgroundColor: AppTheme.background,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting, Champion! 👋',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textColor,
                      ),
                    ),
                    Text(
                      'Keep the streak alive 🔥',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Motivation Card
                  _buildMotivationCard(),
                  const Gap(20),

                  // Progress
                  if (_habits.isNotEmpty) ...[
                    _buildProgressCard(),
                    const Gap(20),
                  ],

                  // Today's habits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Habits",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor,
                        ),
                      ),
                      Text(
                        '$_completedCount/${_habits.length}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),

                  if (_habits.isEmpty)
                    _buildEmptyState()
                  else
                    ..._habits.map((h) => HabitTile(
                          habit: h,
                          onToggle: () => _toggle(h),
                          showStreak: true,
                        )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _loadingMotivation
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 18)),
                    const Gap(8),
                    Text(
                      'AI Coach Says',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Text(
                  _motivation,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
              Text(
                '${(_completionRate * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _completionRate,
              backgroundColor: AppTheme.background,
              valueColor: const AlwaysStoppedAnimation(AppTheme.success),
              minHeight: 8,
            ),
          ),
          const Gap(12),
          Text(
            _completionRate == 1
                ? '🎉 All done! Amazing day!'
                : '$_completedCount of ${_habits.length} habits completed',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 48)),
          const Gap(16),
          Text(
            'No habits yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor,
            ),
          ),
          const Gap(8),
          Text(
            'Add your first habit and start building a better you!',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
