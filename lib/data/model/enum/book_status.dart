enum BookStatus {
  available("AVAILABLE"),
  reserved("RESERVED"),
  taken("TAKEN");

  final String value;
  const BookStatus(this.value);

  static BookStatus fromString(String value) {
    return BookStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookStatus.available,
    );
  }
}
