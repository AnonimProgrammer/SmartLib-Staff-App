enum NotificationType {
  email("EMAIL"),
  sms("SMS"),
  app("APP");

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => NotificationType.app,
    );
  }
}
