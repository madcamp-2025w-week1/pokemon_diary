import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'services/services.dart';

void main() {
  runApp(const PokemonDiaryApp());
}

class PokemonDiaryApp extends StatelessWidget {
  const PokemonDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PokemonApiService>(
          create: (_) => PokemonApiService(),
        ),
        Provider<DbHelper>(
          create: (_) => DbHelper.instance,
        ),
      ],
      child: MaterialApp(
        title: 'Pokemon Emotion Diary',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
