import 'package:dart_sentiment/dart_sentiment.dart';

class SentimentService {
  final _sentimentAnalyzer = Sentiment();

  // emotion lexicon 
  final List<String> joyWords = [
    "happy", "excited", "amazing", "love", "great", "awesome", "wonderful", 
    "best", "yay", "fun", "enjoy", "win", "victory"
  ];

  final List<String> sadWords = [
    "sad", "depressed", "cry", "crying", "lonely", "tear", "miss", "grief", 
    "bad", "sorry", "hurt", "fail", "lost"
  ];

  final List<String> angryWords = [
    "angry", "stress", "mad", "hate", "furious", "rage", "stupid", "annoy", 
    "fight", "destroy", "busy", "deadline", "pressure"
  ];

  // calm will be the default emotion if none of the other three apply

  String analyzeSentiment(String text) {
    String processedText = text.toLowerCase();
    
    // Get Sentiment Score (-5 to +5)
    Map<String, dynamic> result = _sentimentAnalyzer.analysis(processedText);
    int score = result['score'];

    // --- LOGIC TREE ---
    if (score < 0) {
      // === NEGATIVE MOOD ===
      if (_containsAny(text, angryWords)) {
        return "angry";
      } else if (_containsAny(text, sadWords)) {
        return "sad";
      } else {
        return "sad"; // Default Negative
      }
      } else if (score > 0) {
        // === POSITIVE MOOD ===
        if (_containsAny(text, joyWords)){
          return "joy";
        }
      }
    // === NEUTRAL MOOD ===
    return "calm";
  }

  bool _containsAny(String text, List<String> list) {
    for (var word in list) {
      if (text.contains(word)) return true;
    }
    return false;
  }
}

