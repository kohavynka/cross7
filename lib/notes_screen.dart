import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note_model.dart';
import 'database_helper.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  String? errorMessage;
  late DatabaseHelper _databaseHelper;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadNotes(); // Завантаження нотаток при ініціалізації екрану
  }

  // Метод для завантаження нотаток із бази даних
  _loadNotes() async {
    final notes = await _databaseHelper.getNotes();
    setState(() {
      _notes = notes; // Оновлення списку нотаток
    });
  }

  // Метод для додавання нової нотатки
  _addNote() async {
    if (_controller.text.isEmpty) {
      setState(() {
        errorMessage = 'Value is required'; // Валідація на порожнє поле
      });
      return;
    }

    final note = Note(
      text: _controller.text,
      date: DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now()),
    );

    // Додавання нотатки в базу даних
    await _databaseHelper.insertNote(note);
    _controller.clear(); // Очищення поля вводу
    setState(() {
      errorMessage = null; // Скидання повідомлення про помилку
    });
    _loadNotes(); // Оновлення списку нотаток після додавання
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Поле для введення нової нотатки та кнопка "Add"
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87, // Колір фону
                    minimumSize: Size(100, 55), // Розмір кнопки
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Квадратні кути
                    ),
                  ),
                  onPressed: _addNote, // Додаємо нотатку при натисканні на кнопку
                  child: Text(
                    'Add', // Напис на кнопці
                    style: TextStyle(
                      color: Colors.white, // Колір тексту
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            // Повідомлення про помилку, якщо поле порожнє
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            Divider(color: Colors.grey),
            // Список нотаток
            Expanded(
              child: _notes.isEmpty
                  ? Center(child: Text("No notes yet"))
                  : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(note.text),
                      trailing: Text(note.date),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
