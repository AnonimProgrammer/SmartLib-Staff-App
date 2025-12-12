enum ReservationStatus {
  active("ACTIVE"),
  cancelled("CANCELLED"),
  fulfilled("FULFILLED");

  final String value;
  const ReservationStatus(this.value);

  static ReservationStatus fromString(String value) {
    return ReservationStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => ReservationStatus.active,
    );
  }
}
