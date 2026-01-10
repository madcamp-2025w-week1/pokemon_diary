import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/diary_provider.dart';

class Tab2Diary extends StatelessWidget {
  const Tab2Diary({super.key});

  Color _getSentimentColor(String sentiment) {
    final normalized = sentiment.trim().toLowerCase();
    if (normalized == 'joy' || normalized == 'happy') {
      return Colors.amber.shade600;
    }
    if (normalized == 'angry' || normalized == 'stress') {
      return Colors.deepOrange.shade400;
    }
    if (normalized == 'sad' || normalized == 'depressed') {
      return Colors.indigo.shade400;
    }
    if (normalized == 'calm' || normalized == 'normal') {
      return Colors.teal.shade400;
    }
    return Colors.grey.shade400;
  }

  String _capitalizeWords(String text) {
    final parts = text.trim().split(RegExp(r'\s+'));
    return parts
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  String _pokemonIconUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/$id.png';
  }

  String _monthLabel(DateTime date) {
    const months = <String>[
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();

    if (diaryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (diaryProvider.diaries.isEmpty) {
      return const Center(
        child: Text('No diaries yet. Go draft your first Pokemon!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: diaryProvider.diaries.length,
      itemBuilder: (context, index) {
        final diary = diaryProvider.diaries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DiaryCard(
            diary: diary,
            iconUrl: _pokemonIconUrl(diary.pokemonId),
            monthLabelBuilder: _monthLabel,
            sentimentColor: _getSentimentColor(diary.sentiment),
            sentimentLabel: _capitalizeWords(diary.sentiment),
          ),
        );
      },
    );
  }
}

class DiaryCard extends StatelessWidget {
  final Diary diary;
  final String iconUrl;
  final String Function(DateTime date) monthLabelBuilder;
  final Color sentimentColor;
  final String sentimentLabel;

  const DiaryCard({
    super.key,
    required this.diary,
    required this.iconUrl,
    required this.monthLabelBuilder,
    required this.sentimentColor,
    required this.sentimentLabel,
  });

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(diary.date);
    final monthText = parsedDate != null ? monthLabelBuilder(parsedDate) : '---';
    final dayText = parsedDate != null
        ? parsedDate.day.toString().padLeft(2, '0')
        : '--';

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  iconUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(width: 50, height: 50);
                  },
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      dayText,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sentimentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sentimentLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              diary.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
