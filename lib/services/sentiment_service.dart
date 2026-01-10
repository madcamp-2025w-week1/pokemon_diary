import 'package:dart_sentiment/dart_sentiment.dart';

class SentimentService {
  final _sentimentAnalyzer = Sentiment();

  // emotions lexicon
  // Electric, Flying, Fairy
  final List<String> joyWords = [
    "happy", "excited", "amazing", "love", "great", "awesome", "wonderful", 
    "best", "yay", "fun", "enjoy", "win", "victory",
    "delighted", "cheerful", "glad", "grateful", "blessed", "fantastic", 
    "proud", "success", "laugh", "laughing", "smile", "smiling", "optimistic",
    "thrilled", "lucky", "perfect", "favorite", "liked", "hope", "energetic",
    "yummy", "delicious", "party", "celebrate", "achievement"
  ];

  // Water, Ghost, Ice, Poison, Ground
  final List<String> sadWords = [
    "sad", "depressed", "cry", "crying", "lonely", "tear", "miss", "grief", 
    "bad", "sorry", "hurt", "fail", "lost",
    "broken", "empty", "hopeless", "tired", "exhausted", "pain", "painful",
    "regret", "disappointed", "bummer", "awful", "terrible", "gloomy", 
    "alone", "heartbreak", "missed", "mistake", "guilt", "guilty", "shame",
    "unfortunate", "sick", "ill", "unhappy", "blue", "melancholy", "down", "good"
  ];

  // Fire, Fighting, Dragon, Dark
  final List<String> angryWords = [
    "angry", "stress", "mad", "hate", "furious", "rage", "stupid", "annoy", 
    "fight", "destroy", "busy", "deadline", "pressure",
    "frustrated", "frustrating", "irritated", "irritating", "upset", "livid",
    "jealous", "envy", "hated", "sucks", "worst", "damn", "idiot", "dumb",
    "crazy", "scream", "yell", "shout", "punch", "conflict", "argument",
    "enemy", "rude", "mean", "unfair", "betrayed", "cheated", "hostile",
    "panic", "nervous", "anxious", "overwhelmed", "tense"
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

