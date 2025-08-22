import 'package:intl/intl.dart';

String formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  return '${diff.inDays} days ago';
}

DateTime parseRegDate(String regDate) {
  return DateFormat("yyyy-MM-dd HH:mm:ss").parse(regDate, true).toLocal();
}
