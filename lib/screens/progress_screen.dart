import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Habit> _habits = [];
  String _analysis = '';
  bool _loadingAnalysis = true;
  final _gemini = GeminiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final habits = await StorageService.getHabits();
    setState(() => _habits = habits);
    final analysis = await _gemini.analyzeProgress(habits);
    setState(() {
      _analysis = analysis;
      _loadingAnalysis = false;
    });
  }

  List<double> get _last7DaysRates {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      if (_habits.isEmpty) return 0.0;
      final completed = _habits.where((h) => h.completedDates.contains(dateStr)).length;
      return completed / _habits.length;
    });
  }

  int get _bestStreak => _habits.isEmpty
      ? 0
      : _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  String _dayLabel(int index) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - index));
    return days[day.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final rates = _last7DaysRates;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        backgroundColor: AppTheme.card,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Stats row
            Row(
              children: [
                _statCard('Total Habits', '${_habits.length}', '📋'),
                const Gap(12),
                _statCard('Best Streak', '${_bestStreak}d 🔥', '🏆'),
                const Gap(12),
                _statCard(
                  'Today',
                  _habits.isEmpty
                      ? '0%'
                      : '${((_habits.where((h) => h.isCompletedToday).length / _habits.length) * 100).toInt()}%',
                  '✅',
                ),
              ],
            ),
            const Gap(24),

            // Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last 7 Days',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const Gap(20),
                  SizedBox(
                    height: 160,
                    child: _habits.isEmpty
                        ? Center(child: Text('No data yet', style: GoogleFonts.inter(color: AppTheme.muted)))
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 1,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) => Text(
                                      _dayLabel(val.toInt()),
                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.muted),
                                    ),
                                  ),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(
                                7,
                                (i) => BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: rates[i],
                                      color: rates[i] > 0.7
                                          ? AppTheme.success
                                          : rates[i] > 0.3
                                              ? AppTheme.primary
                                              : AppTheme.cardBorder,
                                      width: 28,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const Gap(20),

            // AI Analysis
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withOpacity(0.15), AppTheme.card],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🤖', style: TextStyle(fontSize: 18)),
                      const Gap(8),
                      Text(
                        'AI Analysis',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  _loadingAnalysis
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2))
                      : Text(
                          _analysis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textColor,
                            height: 1.6,
                          ),
                        ),
                ],
              ),
            ),
            const Gap(20),

            // Streak leaderboard
            if (_habits.isNotEmpty) ...[
              Text(
                '🔥 Streak Leaders',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor,
                ),
              ),
              const Gap(12),
              ...(List<Habit>.from(_habits)
                ..sort((a, b) => b.streak.compareTo(a.streak)))
                  .map((h) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Text(h.emoji, style: const TextStyle(fontSize: 22)),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                h.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ),
                            Text(
                              '${h.streak} 🔥',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accent,
                              ),
                            ),
                          ],
                        ),
                      )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const Gap(6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
