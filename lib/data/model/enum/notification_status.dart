enum NotificationStatus {
  sent("SENT"),
  failed("FAILED");

  final String value;
  const NotificationStatus(this.value);

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => NotificationStatus.failed,
    );
  }
}
