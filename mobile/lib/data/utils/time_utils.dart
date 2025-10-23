
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;



String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inDays >= 7) {
    final formatter = DateFormat('MMM d, yyyy'); 
    return timeago.format(dateTime);
  } else {
    return timeago.format(dateTime);
  }
}

