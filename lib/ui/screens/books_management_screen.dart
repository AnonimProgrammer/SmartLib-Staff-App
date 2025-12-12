import 'package:flutter/material.dart';
import 'package:smartlib_staff_app/data/model/book.dart';
import 'package:smartlib_staff_app/data/model/enum/genre.dart';
import 'package:smartlib_staff_app/data/model/enum/language.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_book_repository.dart';

class BooksManagementScreen extends StatefulWidget {
  const BooksManagementScreen({super.key});

  @override
  State<BooksManagementScreen> createState() => _BooksManagementScreenState();
}

class _BooksManagementScreenState extends State<BooksManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  final MockBookRepository _repo = MockBookRepository();
  late Future<List<Book>> _futureBooks;

  @override
  void initState() {
    super.initState();
    _futureBooks = _loadBooks();
  }

  Future<List<Book>> _loadBooks() async {
    return _repo.getAllBooks(
      search: _searchController.text,
      status: _selectedFilter,
    );
  }

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books Management'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddBookDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3E2723),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _futureBooks = _loadBooks();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by title, author, or genre...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Books')),
                      DropdownMenuItem(
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'Reserved',
                        child: Text('Reserved'),
                      ),
                      DropdownMenuItem(value: 'Taken', child: Text('Taken')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                        _futureBooks = _loadBooks();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _futureBooks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No books found"));
                }

                final books = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Column(
                      children: [
                        _buildTableHeader(),

                        for (var book in books) ...[
                          _BookRow(
                            title: book.title,
                            author: book.author,
                            genre: book.genre?.value ?? "Unknown",
                            language: book.language?.value ?? "Unknown",
                            location:
                                "R${book.shelfRow}-C${book.shelfCabinet}-S${book.shelfNumber}",
                            totalCopies: book.totalCopies,
                            availableCopies: book.availableCopies,
                            status: _statusOf(book),
                            onEdit: () => _showEditBookDialog(context, book),
                            onDelete: () =>
                                _showDeleteConfirmation(context, book.bookId),
                          ),
                          const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFEBE9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text(
              'Book Title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Author',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text('Genre', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              'Language',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Copies',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _statusOf(Book b) {
    if (b.availableCopies == 0) return "Taken";
    if (b.availableCopies < b.totalCopies) return "Reserved";
    return "Available";
  }

  Future<void> _deleteBook(BuildContext context, int bookId) async {
    await _repo.deleteBook(bookId);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Book deleted successfully')));

    setState(() {
      _futureBooks = _loadBooks();
    });
  }

  void _showAddBookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddBookDialog(repo: _repo),
    ).then((added) {
      if (added == true) {
        setState(() {
          _futureBooks = _loadBooks();
        });
      }
    });
  }

  void _showEditBookDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (_) => EditBookDialog(repo: _repo, book: book),
    ).then((updated) {
      if (updated == true) {
        setState(() {
          _futureBooks = _loadBooks();
        });
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, int bookId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text(
          'Are you sure you want to delete this book? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _deleteBook(context, bookId);
              setState(() {
                _futureBooks = _loadBooks();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final String title;
  final String author;
  final String genre;
  final String language;
  final String location;
  final int totalCopies;
  final int availableCopies;
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookRow({
    required this.title,
    required this.author,
    required this.genre,
    required this.language,
    required this.location,
    required this.totalCopies,
    required this.availableCopies,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Available':
        statusColor = Colors.green;
        break;
      case 'Reserved':
        statusColor = Colors.orange;
        break;
      case 'Taken':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(author)),
          Expanded(child: Text(genre)),
          Expanded(child: Text(language)),
          Expanded(child: Text(location)),
          Expanded(child: Text('$availableCopies / $totalCopies')),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  color: const Color(0xFF3E2723),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddBookDialog extends StatefulWidget {
  final MockBookRepository repo;
  const AddBookDialog({super.key, required this.repo});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _languageController = TextEditingController();
  final _copiesController = TextEditingController();
  int _selectedRow = 1;
  int _selectedCabinet = 1;
  int _selectedShelf = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Book',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Book Title',
                    hintText: 'Enter book title',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    hintText: 'Enter author name',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _genreController,
                        decoration: const InputDecoration(
                          labelText: 'Genre',
                          hintText: 'e.g., Fiction',
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _languageController,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                          hintText: 'e.g., English',
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _copiesController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Copies',
                    hintText: 'Enter number',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (int.tryParse(value!) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedRow,
                        decoration: const InputDecoration(
                          labelText: 'Row (1-15)',
                        ),
                        items: List.generate(15, (i) => i + 1)
                            .map(
                              (e) =>
                                  DropdownMenuItem(value: e, child: Text('$e')),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRow = value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCabinet,
                        decoration: const InputDecoration(
                          labelText: 'Cabinet (1-10)',
                        ),
                        items: List.generate(10, (i) => i + 1)
                            .map(
                              (e) =>
                                  DropdownMenuItem(value: e, child: Text('$e')),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCabinet = value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedShelf,
                        decoration: const InputDecoration(
                          labelText: 'Shelf (1-20)',
                        ),
                        items: List.generate(20, (i) => i + 1)
                            .map(
                              (e) =>
                                  DropdownMenuItem(value: e, child: Text('$e')),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedShelf = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final book = Book(
                            bookId: DateTime.now().millisecondsSinceEpoch,
                            title: _titleController.text.trim(),
                            author: _authorController.text.trim(),
                            genre: Genre.fromString(
                              _genreController.text.trim(),
                            ),
                            language: Language.fromString(
                              _languageController.text.trim(),
                            ),
                            totalCopies: int.parse(_copiesController.text),
                            availableCopies: int.parse(_copiesController.text),
                            shelfRow: _selectedRow,
                            shelfCabinet: _selectedCabinet,
                            shelfNumber: _selectedShelf,
                          );

                          await widget.repo.addBook(book);
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Add Book'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditBookDialog extends StatefulWidget {
  final MockBookRepository repo;
  final Book book;

  const EditBookDialog({super.key, required this.repo, required this.book});

  @override
  State<EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<EditBookDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _genreController;
  late TextEditingController _languageController;
  late TextEditingController _copiesController;

  late int _selectedRow;
  late int _selectedCabinet;
  late int _selectedShelf;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleController = TextEditingController(text: b.title);
    _authorController = TextEditingController(text: b.author);
    _genreController = TextEditingController(text: b.genre?.value ?? '');
    _languageController = TextEditingController(text: b.language?.value ?? '');
    _copiesController = TextEditingController(text: b.totalCopies.toString());

    _selectedRow = b.shelfRow;
    _selectedCabinet = b.shelfCabinet;
    _selectedShelf = b.shelfNumber;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _languageController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Book',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Book Title'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _genreController,
                        decoration: const InputDecoration(labelText: 'Genre'),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _languageController,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _copiesController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Copies',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (int.tryParse(value!) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedRow,
                        decoration: const InputDecoration(
                          labelText: 'Row (1-15)',
                        ),
                        items: List.generate(15, (i) => i + 1)
                            .map(
                              (e) =>
                                  DropdownMenuItem(value: e, child: Text('$e')),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRow = value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCabinet,
                        decoration: const InputDecoration(
                          labelText: 'Cabinet (1-10)',
                        ),
                        items: List.generate(10, (i) => i + 1)
                            .map(
                              (e) =>
                                  DropdownMenuItem(value: e, child: Text('$e')),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCabinet = value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedShelf,
                        decoration: const InputDecoration(
                          labelText: 'Shelf (1-20)',
                        ),
                        items: List.generate(20, (i) => i + 1)
                            .map(
                              (e) =>
                                  DropdownMenuItem(value: e, child: Text('$e')),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedShelf = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final totalCopies = int.parse(
                            _copiesController.text.trim(),
                          );

                          final updated = Book(
                            bookId: widget.book.bookId,
                            title: _titleController.text.trim(),
                            author: _authorController.text.trim(),
                            genre: Genre.fromString(
                              _genreController.text.trim(),
                            ),
                            language: Language.fromString(
                              _languageController.text.trim(),
                            ),
                            totalCopies: totalCopies,
                            // simple assumption: keep availableCopies as min(old, total)
                            availableCopies:
                                widget.book.availableCopies > totalCopies
                                ? totalCopies
                                : widget.book.availableCopies,
                            shelfRow: _selectedRow,
                            shelfCabinet: _selectedCabinet,
                            shelfNumber: _selectedShelf,
                          );

                          await widget.repo.updateBook(updated);
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
