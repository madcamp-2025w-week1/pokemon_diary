import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_keys.dart';

class SentimentService {
  // Use the variable from secrets.dart
  static const _apiKey = huggingFaceAPIKey; 
  static const _modelUrl = "https://router.huggingface.co/hf-inference/models/SamLowe/roberta-base-go_emotions";
  Future<String> analyzeSentiment(String text) async {
    int maxRetries = 5;
    
    for (int i = 0; i < maxRetries; i++) {
      final response = await http.post(
        Uri.parse(_modelUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"inputs": text}),
      );

      if (response.statusCode == 200) {
        // Success! Parse the result.
        // The API returns a list of lists: [[{"label": "joy", "score": 0.9}, ...]]
        final List<dynamic> data = jsonDecode(response.body);
        final List<dynamic> emotions = data[0];

        // Sort by score (confidence) to get the top emotion
        emotions.sort((a, b) => b['score'].compareTo(a['score']));
        return mapEmotionToAvailableEmotions(emotions[0]['label']); // Returns "joy", "sadness", "anger", etc.
      } 
      
      else if (response.statusCode == 503) {
        // === CRITICAL PART: MODEL IS LOADING ===
        // The error usually says "Model is currently loading", estimated_time: 20.0
        final errorBody = jsonDecode(response.body);
        double waitTime = errorBody['estimated_time'] ?? 10.0;
        
        debugPrint("Model is sleeping. Waking up... Waiting ${waitTime}s");
        
        // Wait for the suggested time before retrying
        await Future.delayed(Duration(seconds: waitTime.ceil()));
        continue; // Retry the loop
      } else {
        debugPrint("Error: ${response.statusCode} ${response.body}");
        return 'calm'; // default emotion
      }
    }
    return 'calm';
  }

  String mapEmotionToAvailableEmotions(String mlLabel) {
    // === HIGH ENERGY / POSITIVE ===
  // "I am pumped!" "Best day ever!"
  const joySet = {
    'excitement', 'joy', 'love', 'admiration', 
    'optimism', 'pride', 'gratitude', 'amusement', 'desire'
  };

  // === LOW ENERGY / NEGATIVE ===
  // "I feel empty." "I messed up."
  const sadSet = {
    'sadness', 'grief', 'disappointment', 
    'remorse', 'embarrassment', 
  };

  // === HIGH ENERGY / NEGATIVE ===
  // "I am stressing out!" "Leave me alone."
  const angrySet = {
    'anger', 'annoyance', 'disapproval', 'disgust', 
    'fear', 'nervousness' // Nervousness is high energy stress!
  };
  
  // === LOW ENERGY / POSITIVE (The "Calm" Bucket) ===
  // "I agree." "I feel better now." "I wonder why?"
  const calmSet = {
    'relief',      // The feeling of stress leaving
    'approval',    // "This is fine", "I accept this"
    'realization', // "Oh, I see now"
    'curiosity',   // "I wonder..."
    'caring',      // "I care about this" (Warmth, not hype)
    'confusion',   // "I'm not sure" (Neutral/Calm state)
    'neutral'      // Explicit neutral label
  };

    if (joySet.contains(mlLabel)) return "joy";
    if (sadSet.contains(mlLabel)) return "sad";
    if (angrySet.contains(mlLabel)) return "angry";
    return "calm";
  }


  
}