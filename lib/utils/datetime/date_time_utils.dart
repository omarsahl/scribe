import 'package:intl/intl.dart';

/// Returns the current milliseconds since epoch in UTC.
int get utcMillis => DateTime.now().toUtc().millisecondsSinceEpoch;

/// Converts the given [utcMillis] to local [DateTime].
DateTime utcTimestampToLocalTime(int utcMillis) =>
    DateTime.fromMillisecondsSinceEpoch(utcMillis, isUtc: true).toLocal();

final DateFormat defaultDateTimeFormat = DateFormat('dd MMM, yyyy hh:mm a');

/// Converts the given [utcMillis] to local [DateTime] and then formats it using the given [dateFormat].
/// If [dateFormat] is null, [defaultDateTimeFormat] will be used instead.
String formatTimestamp(int utcMillis, [DateFormat? dateFormat]) {
  return defaultDateTimeFormat.format(utcTimestampToLocalTime(utcMillis));
}

String _formatDurationComponent(int duration) => NumberFormat('00').format(duration);

String formatDuration(Duration duration) {
  String twoDigitMinutes = _formatDurationComponent(duration.inMinutes.remainder(60));
  String twoDigitSeconds = _formatDurationComponent(duration.inSeconds.remainder(60));
  return "${_formatDurationComponent(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}