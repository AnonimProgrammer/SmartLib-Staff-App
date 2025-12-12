class Reservation {
  final String id;
  final String bookId;
  final String memberId;
  final DateTime reservationDate;
  final DateTime expiryDate;
  final ReservationStatus status;

  Reservation({
    required this.id,
    required this.bookId,
    required this.memberId,
    required this.reservationDate,
    required this.expiryDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'memberId': memberId,
      'reservationDate': reservationDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      bookId: json['bookId'],
      memberId: json['memberId'],
      reservationDate: DateTime.parse(json['reservationDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
    );
  }
}

enum ReservationStatus { pending, approved, fulfilled, expired, cancelled }
