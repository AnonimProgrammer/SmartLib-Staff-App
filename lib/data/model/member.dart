class Member {
  final int memberId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final DateTime registrationDate;
  final double outstandingFines;

  Member({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.registrationDate,
    required this.outstandingFines,
  });

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      memberId: map['member_id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: map['email'],
      phone: map['phone'],
      registrationDate: DateTime.parse(map['registration_date']),
      outstandingFines: (map['outstanding_fines'] as num).toDouble(),
    );
  }
}
