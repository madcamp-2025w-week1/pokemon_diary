class DateHelper {
  static const List<String> _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  /// Returns "JAN 12, 2024"
  /// Used in: DiaryDetailDialog, TrainerCard
  static String formatFullDate(DateTime date) {
    return "${_months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// Helper to parse string first, then format full date
  /// Returns original string if parsing fails
  static String formatFullDateFromString(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return formatFullDate(date);
  }

  /// Returns "1/12/24"
  /// Used in: Diary List Tile
  static String formatShortDate(DateTime date) {
    final year = date.year % 100;
    return '${date.month}/${date.day}/$year';
  }

  /// Helper to parse string first, then format short date
  static String formatShortDateFromString(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '--/--/--';
    return formatShortDate(date);
  }
}