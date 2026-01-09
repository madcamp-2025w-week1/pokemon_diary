import 'dart:math';

class SentimentService {
  static const List<String> _sentiments = [
    'joy',
    'sad',
    'angry',
    'calm',
  ];

  String analyzeSentiment(String text) {
    final random = Random();
    return _sentiments[random.nextInt(_sentiments.length)];
  }
}