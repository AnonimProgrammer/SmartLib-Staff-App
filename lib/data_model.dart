// Book Model
class Book {
  final String id;
  final String name;
  final String author;
  final String language;
  final String genre;
  final int totalCopies;
  final BookLocation location;
  final BookStatus status;
  final List<BorrowRecord> borrowHistory;

  Book({
    required this.id,
    required this.name,
    required this.author,
    required this.language,
    required this.genre,
    required this.totalCopies,
    required this.location,
    required this.status,
    this.borrowHistory = const [],
  });

  int get availableCopies => totalCopies - status.borrowedCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'language': language,
      'genre': genre,
      'totalCopies': totalCopies,
      'location': location.toJson(),
      'status': status.toJson(),
      'borrowHistory': borrowHistory.map((e) => e.toJson()).toList(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      name: json['name'],
      author: json['author'],
      language: json['language'],
      genre: json['genre'],
      totalCopies: json['totalCopies'],
      location: BookLocation.fromJson(json['location']),
      status: BookStatus.fromJson(json['status']),
      borrowHistory:
          (json['borrowHistory'] as List?)
              ?.map((e) => BorrowRecord.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// Book Location Model (Row, Cabinet, Shelf)
class BookLocation {
  final int row; // 1-15
  final int cabinet; // 1-10
  final int shelf; // 1-20

  BookLocation({required this.row, required this.cabinet, required this.shelf});

  String get displayLocation => 'R$row-C$cabinet-S$shelf';

  Map<String, dynamic> toJson() {
    return {'row': row, 'cabinet': cabinet, 'shelf': shelf};
  }

  factory BookLocation.fromJson(Map<String, dynamic> json) {
    return BookLocation(
      row: json['row'],
      cabinet: json['cabinet'],
      shelf: json['shelf'],
    );
  }
}

// Book Status Model
class BookStatus {
  final BookAvailability availability;
  final int borrowedCount;
  final int reservedCount;

  BookStatus({
    required this.availability,
    required this.borrowedCount,
    required this.reservedCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'availability': availability.toString(),
      'borrowedCount': borrowedCount,
      'reservedCount': reservedCount,
    };
  }

  factory BookStatus.fromJson(Map<String, dynamic> json) {
    return BookStatus(
      availability: BookAvailability.values.firstWhere(
        (e) => e.toString() == json['availability'],
        orElse: () => BookAvailability.available,
      ),
      borrowedCount: json['borrowedCount'] ?? 0,
      reservedCount: json['reservedCount'] ?? 0,
    );
  }
}

enum BookAvailability { available, reserved, taken, unavailable }

// Member Model
class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime registrationDate;
  final List<String> currentlyBorrowedBookIds;
  final List<Fine> fines;
  final List<String> borrowingHistory;
  final List<String> wishlist;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.registrationDate,
    this.currentlyBorrowedBookIds = const [],
    this.fines = const [],
    this.borrowingHistory = const [],
    this.wishlist = const [],
    required int outstandingFines,
  });

  String get fullName => '$firstName $lastName';

  bool get hasUnpaidFines =>
      fines.any((fine) => fine.status == FineStatus.unpaid);

  double get totalUnpaidFines => fines
      .where((fine) => fine.status == FineStatus.unpaid)
      .fold(0.0, (sum, fine) => sum + fine.amount);

  int get currentBorrowCount => currentlyBorrowedBookIds.length;

  bool get canBorrow => !hasUnpaidFines && currentBorrowCount < 10;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'registrationDate': registrationDate.toIso8601String(),
      'currentlyBorrowedBookIds': currentlyBorrowedBookIds,
      'fines': fines.map((e) => e.toJson()).toList(),
      'borrowingHistory': borrowingHistory,
      'wishlist': wishlist,
    };
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      registrationDate: DateTime.parse(json['registrationDate']),
      currentlyBorrowedBookIds: List<String>.from(
        json['currentlyBorrowedBookIds'] ?? [],
      ),
      fines:
          (json['fines'] as List?)?.map((e) => Fine.fromJson(e)).toList() ?? [],
      borrowingHistory: List<String>.from(json['borrowingHistory'] ?? []),
      wishlist: List<String>.from(json['wishlist'] ?? []),
      outstandingFines: 0,
    );
  }
}

// Borrow Record Model
class BorrowRecord {
  final String id;
  final String bookId;
  final String memberId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final BorrowStatus status;

  BorrowRecord({
    required this.id,
    required this.bookId,
    required this.memberId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
  });

  bool get isOverdue =>
      status != BorrowStatus.returned && DateTime.now().isAfter(dueDate);

  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(dueDate).inDays : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'memberId': memberId,
      'borrowDate': borrowDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory BorrowRecord.fromJson(Map<String, dynamic> json) {
    return BorrowRecord(
      id: json['id'],
      bookId: json['bookId'],
      memberId: json['memberId'],
      borrowDate: DateTime.parse(json['borrowDate']),
      dueDate: DateTime.parse(json['dueDate']),
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'])
          : null,
      status: BorrowStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => BorrowStatus.active,
      ),
    );
  }
}

enum BorrowStatus { active, overdue, returned }

// Fine Model
class Fine {
  final String id;
  final String memberId;
  final String borrowRecordId;
  final double amount;
  final String reason;
  final DateTime createdDate;
  final DateTime? paidDate;
  final FineStatus status;

  Fine({
    required this.id,
    required this.memberId,
    required this.borrowRecordId,
    required this.amount,
    required this.reason,
    required this.createdDate,
    this.paidDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'borrowRecordId': borrowRecordId,
      'amount': amount,
      'reason': reason,
      'createdDate': createdDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'],
      memberId: json['memberId'],
      borrowRecordId: json['borrowRecordId'],
      amount: json['amount'].toDouble(),
      reason: json['reason'],
      createdDate: DateTime.parse(json['createdDate']),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      status: FineStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => FineStatus.unpaid,
      ),
    );
  }
}

enum FineStatus { unpaid, paid, waived }

// Wishlist Item Model
class WishlistItem {
  final String id;
  final String memberId;
  final String bookName;
  final String author;
  final DateTime requestDate;
  final WishlistStatus status;
  final String? notes;

  WishlistItem({
    required this.id,
    required this.memberId,
    required this.bookName,
    required this.author,
    required this.requestDate,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'bookName': bookName,
      'author': author,
      'requestDate': requestDate.toIso8601String(),
      'status': status.toString(),
      'notes': notes,
    };
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      memberId: json['memberId'],
      bookName: json['bookName'],
      author: json['author'],
      requestDate: DateTime.parse(json['requestDate']),
      status: WishlistStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => WishlistStatus.pending,
      ),
      notes: json['notes'],
    );
  }
}

enum WishlistStatus { pending, acquired, rejected }
