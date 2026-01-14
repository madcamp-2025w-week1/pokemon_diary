import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Removed
import 'package:pokemon_diary/services/sound_service.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../utils/utils.dart';
import '../providers/providers.dart';

class DiaryDetailDialog extends StatefulWidget {
  final Diary diary;
  final Pokemon? pokemon;

  const DiaryDetailDialog({
    super.key, 
    required this.diary, 
    this.pokemon
  });

  @override
  State<DiaryDetailDialog> createState() => _DiaryDetailDialogState();
}

class _DiaryDetailDialogState extends State<DiaryDetailDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isKorean = settings.isKorean;

    final theme = UiThemeHelper.getSentimentTheme(widget.diary.sentiment);
    
    // [Refactor] Use helper
    final pixelStyle = UiThemeHelper.getPixelFont(
      const TextStyle(
        color: Color(0xFF2d3436),
        fontSize: 10,
        height: 1.5,
      ),
      isKorean: isKorean,
    );

    // Display Name Logic
    final pokemonName = widget.pokemon != null 
        ? (isKorean ? widget.pokemon!.koreanName : widget.pokemon!.englishName.toUpperCase()) 
        : "UNKNOWN";
    
    final outerColor = theme['outer']!;
    final borderColor = theme['border']!;
    final innerColor = theme['inner']!;
    final paperColor = theme['paper']!;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: outerColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 3), 
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(child: Container(color: innerColor)),
                Positioned(
                  top: 50, bottom: 0, left: 0, right: 0,
                  child: Container(color: paperColor),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: StripePainter(stripeColor: Colors.black.withValues(alpha: 0.05))),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 2), 
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: borderColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                DateHelper.formatFullDateFromString(widget.diary.date),
                                style: pixelStyle.copyWith(color: Colors.white, fontSize: 10),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                SoundService().playCardSelectSound();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor),
                                ),
                                child: Icon(Icons.close, size: 14, color: borderColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: borderColor,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2,2))],
                                    ),
                                    child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.diary.sentiment.toUpperCase(),
                                          style: pixelStyle.copyWith(
                                            color: borderColor,
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${settings.getText('FEAT')} $pokemonName", 
                                          style: pixelStyle.copyWith(fontSize: 8, color: Colors.black54),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),

                              Container(
                                constraints: const BoxConstraints(minHeight: 100),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: borderColor, width: 1.5),
                                ),
                                child: Text(
                                  widget.diary.content,
                                  style: pixelStyle.copyWith(fontSize: 11, height: 1.6),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}