class Quote {
  final int? id;
  final String quote;
  String category;
  DateTime dateTime;

  Quote({
    this.id,
    required this.quote,
    required this.category,
    required this.dateTime,
  });

  // Convert a Map to a Quote object
  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['_id'],
      quote: map['quote'],
      category: map['category'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }

  // Convert a Quote object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'quote': quote,
      'category': category,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
