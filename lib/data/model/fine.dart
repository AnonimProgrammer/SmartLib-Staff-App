class Fine {
  final int fineId;
  final int memberId;
  final double amount;
  final String? reason;
  final DateTime issuedDate;
  final bool paid;
  final int? borrowId;

  Fine({
    required this.fineId,
    required this.memberId,
    required this.amount,
    this.reason,
    required this.issuedDate,
    required this.paid,
    this.borrowId,
  });

  factory Fine.fromMap(Map<String, dynamic> map) {
    return Fine(
      fineId: map['fine_id'],
      memberId: map['member_id'],
      amount: (map['amount'] as num).toDouble(),
      reason: map['reason'],
      issuedDate: DateTime.parse(map['issued_date']),
      paid: map['paid'] ?? false,
      borrowId: map['borrow_id'],
    );
  }
}
