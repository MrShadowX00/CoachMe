import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final bool showStreak;
  final VoidCallback? onDelete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    this.showStreak = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = habit.isCompletedToday;
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done ? AppTheme.primary.withOpacity(0.5) : AppTheme.cardBorder,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: done ? AppTheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? AppTheme.primary : AppTheme.muted,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const Gap(14),
            Text(habit.emoji, style: const TextStyle(fontSize: 22)),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: done ? AppTheme.muted : AppTheme.textColor,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (showStreak && habit.streak > 0) ...[
                    const Gap(2),
                    Text(
                      '🔥 ${habit.streak} day streak',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
