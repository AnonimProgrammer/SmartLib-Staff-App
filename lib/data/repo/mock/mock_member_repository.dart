import 'dart:async';

import 'package:smartlib_staff_app/data/model/member.dart';

class MockMemberRepository {
  static final MockMemberRepository _instance =
      MockMemberRepository._internal();
  factory MockMemberRepository() => _instance;

  MockMemberRepository._internal();

  /// Fake in-memory DB
  final List<Member> _members = List.generate(
    15,
    (index) => Member(
      memberId: 1000 + index,
      firstName: _sampleNames[index].split(" ")[0],
      lastName: _sampleNames[index].split(" ")[1],
      email: _sampleEmails[index],
      phone: (index % 2 == 0) ? '+994 55 84$index 21 3$index' : null,
      registrationDate: DateTime.utc(2025, 10, 29, 23, 11, 02),
      outstandingFines: (index % 5 == 0) ? index * 3 : 0,
    ),
  );

  /// Simulated GET with optional search
  Future<List<Member>> getAllMembers({String? search}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (search == null || search.trim().isEmpty) {
      return List<Member>.from(_members);
    }

    final query = search.trim().toLowerCase();
    return _members.where((m) {
      return m.firstName.toLowerCase().contains(query) ||
          m.lastName.toLowerCase().contains(query) ||
          m.email.toLowerCase().contains(query);
    }).toList();
  }

  /// Simulated INSERT
  Future<void> createMember({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // simulate DB write

    final newId = (_members.last.memberId + 1);

    _members.add(
      Member(
        memberId: newId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        registrationDate: DateTime.now(),
        outstandingFines: 0,
      ),
    );
  }
}

const _sampleNames = [
  "Alice Johnson",
  "Michael Brown",
  "Sarah Davis",
  "James Wilson",
  "Emily Martinez",
  "David Anderson",
  "Laura Scott",
  "Daniel Harris",
  "Sophia Clark",
  "Matthew Lewis",
  "Olivia Turner",
  "Ethan Walker",
  "Abigail Hall",
  "Henry Young",
  "Samantha King",
];

const _sampleEmails = [
  "alice.j@email.com",
  "michael.b@email.com",
  "sarah.d@email.com",
  "james.w@email.com",
  "emily.m@email.com",
  "david.a@email.com",
  "laura.s@email.com",
  "daniel.h@email.com",
  "sophia.c@email.com",
  "matthew.l@email.com",
  "olivia.t@email.com",
  "ethan.w@email.com",
  "abigail.h@email.com",
  "henry.y@email.com",
  "samantha.k@email.com",
];
