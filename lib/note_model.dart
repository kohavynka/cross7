class Note {
  final int? id;
  final String text;
  final String date;

  Note({this.id, required this.text, required this.date});

  // Перетворення в Map для вставки в БД
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'date': date,
    };
  }

  // Створення об'єкта Note з Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      text: map['text'],
      date: map['date'],
    );
  }
}
