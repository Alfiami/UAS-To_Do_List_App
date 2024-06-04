class Task {
  String id;
  String title;
  DateTime? date;
  String? note;
  bool isFavorite;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.date,
    this.note,
    this.isFavorite = false,
    this.isCompleted = false,
  });

  // Tambahkan metode copyWith
  Task copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? note,
    bool? isFavorite,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
