import 'package:intl/intl.dart';

String formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
}

DateTime parseRegDate(String regDate) {
  return DateFormat("yyyy-MM-dd HH:mm:ss").parse(regDate, true).toLocal();
}
