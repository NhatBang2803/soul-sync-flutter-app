/// Duration formatting utilities
class DurationUtils {
  DurationUtils._();

  /// Format duration from seconds to mm:ss
  static String formatFromSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// Format Duration object to mm:ss
  static String format(Duration? duration) {
    if (duration == null) return '0:00';
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

/// Greeting based on time of day
class GreetingUtils {
  GreetingUtils._();

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }
}
