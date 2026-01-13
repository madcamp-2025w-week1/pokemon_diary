import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../utils/utils.dart';
import '../services/sound_service.dart';
import '../providers/providers.dart'; // Import settings

class BadgeUnlockDialog extends StatefulWidget {
  final PokemonBadge badge;
  final VoidCallback onClose;

  const BadgeUnlockDialog({
    super.key, 
    required this.badge, 
    required this.onClose
  });

  @override
  State<BadgeUnlockDialog> createState() => _BadgeUnlockDialogState();
}

class _BadgeUnlockDialogState extends State<BadgeUnlockDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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

    final pixelStyle = GoogleFonts.pressStart2p(
      color: const Color(0xFF2d3436),
      height: 1.5,
    );
    
    final bool isUnlocked = widget.badge.isUnlocked;
    final baseColor = isUnlocked ? UiThemeHelper.getBadgeColor(widget.badge.id) : const Color(0xFF7f8c8d);
    final mainColor = baseColor;
    final borderColor = isUnlocked ? baseColor.withOpacity(0.6) : const Color(0xFF95a5a6);
    final innerColor = isUnlocked ? baseColor.withOpacity(0.15) : const Color(0xFFbdc3c7);
    final iconColor = mainColor;

    final headerText = isUnlocked ? settings.getText('ACHIEVEMENT') : settings.getText('LOCKED');
    final buttonText = isUnlocked ? settings.getText('AWESOME') : settings.getText('KEEP_GOING');

    const double headerHeight = 45.0; 
    const double whiteStripHeight = 140.0;
    const double firstSectionTotalHeight = headerHeight + whiteStripHeight; 

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: borderColor, 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: innerColor, 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: mainColor, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6), 
              child: Stack(
                children: [
                  Positioned(
                    top: headerHeight, left: 0, right: 0, height: whiteStripHeight, 
                    child: Container(color: Colors.white.withOpacity(0.5)),
                  ),
                  Positioned(
                    top: 0, left: 0, right: 0, height: firstSectionTotalHeight, 
                    child: CustomPaint(painter: StripePainter(stripeColor: Colors.black.withOpacity(0.05))),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: mainColor),
                        child: Text(
                          headerText,
                          textAlign: TextAlign.center,
                          style: pixelStyle.copyWith(color: Colors.white, fontSize: 14, letterSpacing: 1.2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Opacity(
                        opacity: isUnlocked ? 1.0 : 0.5,
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: mainColor, width: 3),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))]
                          ),
                          child: Icon(widget.badge.icon, size: 40, color: iconColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Opacity(
                        opacity: isUnlocked ? 1.0 : 0.6,
                        child: Text(
                          widget.badge.name.toUpperCase(),
                          style: pixelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16), 
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Opacity(
                          opacity: isUnlocked ? 1.0 : 0.7,
                          child: Text(
                            widget.badge.description,
                            style: pixelStyle.copyWith(fontSize: 10, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          SoundService().playCardSelectSound();
                          widget.onClose();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2d3436), width: 2),
                            boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2))],
                          ),
                          child: Text(buttonText, style: pixelStyle.copyWith(fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}