class Memory {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  Memory({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  factory Memory.createNew({required String title, required String content}) {
    return Memory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      date: DateTime.now(),
    );
  }

  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  Memory copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }
}
