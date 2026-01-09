class Diary {
  final int? id;
  final String date;
  final String content;
  final String sentiment;
  final int pokemonId;

  const Diary({
    this.id,
    required this.date,
    required this.content,
    required this.sentiment,
    required this.pokemonId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'content': content,
      'sentiment': sentiment,
      'pokemon_id': pokemonId,
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'] as int?,
      date: map['date'] as String? ?? '',
      content: map['content'] as String? ?? '',
      sentiment: map['sentiment'] as String? ?? '',
      pokemonId: map['pokemon_id'] as int? ?? 0,
    );
  }
}