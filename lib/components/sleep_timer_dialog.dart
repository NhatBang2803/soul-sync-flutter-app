import 'package:flutter/material.dart';
import '../core/core.dart';

class SleepTimerDialog extends StatefulWidget {
  final Duration? currentTimer;
  final Function(Duration?) onTimerSet;

  const SleepTimerDialog({
    super.key,
    this.currentTimer,
    required this.onTimerSet,
  });

  @override
  State<SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<SleepTimerDialog> {
  int? _selectedMinutes;

  final List<int> _presetMinutes = [5, 10, 15, 30, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    if (widget.currentTimer != null) {
      _selectedMinutes = widget.currentTimer!.inMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.bedtime, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Hẹn giờ ngủ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhạc sẽ tự động dừng sau thời gian bạn chọn',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            // Timer options
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetMinutes.map((minutes) {
                final isSelected = _selectedMinutes == minutes;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                    child: Text(
                      _formatMinutes(minutes),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                // Cancel button (only show if timer is active)
                if (widget.currentTimer != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onTimerSet(null);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Hủy hẹn giờ'),
                    ),
                  ),
                if (widget.currentTimer != null) const SizedBox(width: 12),
                // Set button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedMinutes != null
                        ? () {
                            widget.onTimerSet(Duration(minutes: _selectedMinutes!));
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Bắt đầu hẹn giờ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '$hours giờ $mins phút' : '$hours giờ';
    }
  }
}

/// Show sleep timer dialog
Future<void> showSleepTimerDialog(
  BuildContext context, {
  Duration? currentTimer,
  required Function(Duration?) onTimerSet,
}) {
  return showDialog(
    context: context,
    builder: (context) => SleepTimerDialog(
      currentTimer: currentTimer,
      onTimerSet: onTimerSet,
    ),
  );
}
