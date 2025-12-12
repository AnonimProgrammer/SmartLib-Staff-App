import 'package:smartlib_staff_app/data/model/enum/notification_status.dart';
import 'package:smartlib_staff_app/data/model/enum/notification_type.dart';

class NotificationEntry {
  final int notifId;
  final int memberId;
  final NotificationType type;
  final String message;
  final DateTime sentDate;
  final NotificationStatus status;

  NotificationEntry({
    required this.notifId,
    required this.memberId,
    required this.type,
    required this.message,
    required this.sentDate,
    required this.status,
  });

  factory NotificationEntry.fromMap(Map<String, dynamic> map) {
    return NotificationEntry(
      notifId: map['notif_id'],
      memberId: map['member_id'],
      type: NotificationType.fromString(map['type']),
      message: map['message'],
      sentDate: DateTime.parse(map['sent_date']),
      status: NotificationStatus.fromString(map['status']),
    );
  }
}
