import 'dart:async';
import 'package:smartlib_staff_app/data/model/reservation.dart';

class MockReservationRepository {
  static final MockReservationRepository _instance =
      MockReservationRepository._internal();
  factory MockReservationRepository() => _instance;

  MockReservationRepository._internal();

  final List<Reservation> _reservations = [
    Reservation(
      id: 'R1',
      bookId: 'B1',
      memberId: 'M1000',
      reservationDate: DateTime.now().subtract(const Duration(hours: 2)),
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      status: ReservationStatus.pending,
    ),
    Reservation(
      id: 'R2',
      bookId: 'B2',
      memberId: 'M1001',
      reservationDate: DateTime.now().subtract(const Duration(days: 1)),
      expiryDate: DateTime.now().add(const Duration(days: 1)),
      status: ReservationStatus.pending,
    ),
    Reservation(
      id: 'R3',
      bookId: 'B3',
      memberId: 'M1002',
      reservationDate: DateTime.now().subtract(const Duration(hours: 5)),
      expiryDate: DateTime.now().add(const Duration(hours: 19)),
      status: ReservationStatus.pending,
    ),
  ];

  Future<List<Reservation>> getReservations({
    ReservationStatus? statusFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    Iterable<Reservation> result = _reservations;

    if (statusFilter != null) {
      result = result.where((r) => r.status == statusFilter);
    }

    return result.toList();
  }

  Future<void> updateStatus(String id, ReservationStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index != -1) {
      final r = _reservations[index];
      _reservations[index] = Reservation(
        id: r.id,
        bookId: r.bookId,
        memberId: r.memberId,
        reservationDate: r.reservationDate,
        expiryDate: r.expiryDate,
        status: newStatus,
      );
    }
  }
}
