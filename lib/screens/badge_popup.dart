import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

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
    final pixelStyle = GoogleFonts.pressStart2p(
      color: const Color(0xFF2d3436),
      height: 1.5,
    );
    
    final bool isUnlocked = widget.badge.isUnlocked;

    // --- COLORS ---
    final mainColor = isUnlocked ? const Color(0xFFe58e26) : const Color(0xFF7f8c8d);
    final borderColor = isUnlocked ? const Color(0xFFf8c291) : const Color(0xFF95a5a6);
    final innerColor = isUnlocked ? const Color(0xFFfad390) : const Color(0xFFbdc3c7);
    final iconColor = isUnlocked ? const Color(0xFFe58e26) : const Color(0xFF7f8c8d);

    final headerText = isUnlocked ? "ACHIEVEMENT!" : "LOCKED";
    final buttonText = isUnlocked ? "AWESOME!" : "KEEP GOING";

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
                  // 1. BASE BACKGROUND (Provided by Container color)
                  
                  // 2. WHITE SECTION STRIP (The "Trainer Card" Effect)
                  // We position this to sit behind the Icon and Name
                  Positioned(
                    top: 45, // Starts just below the header
                    left: 0,
                    right: 0,
                    height: 140, // Height to cover Icon + Name area
                    child: Container(
                      color: Colors.white.withOpacity(0.5), 
                    ),
                  ),

                  // 3. GLOBAL STRIPES (Overlay on top of background & white strip)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: StripePainter(
                        stripeColor: Colors.black.withOpacity(0.05),
                      ),
                    ),
                  ),

                  // 4. CONTENT COLUMN
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: mainColor,
                        ),
                        child: Text(
                          headerText,
                          textAlign: TextAlign.center,
                          style: pixelStyle.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Icon Circle
                      Opacity(
                        opacity: isUnlocked ? 1.0 : 0.5,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: mainColor, width: 3),
                            boxShadow: const [
                               BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))
                            ]
                          ),
                          child: Icon(
                            widget.badge.icon,
                            size: 40,
                            color: iconColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Badge Name
                      Opacity(
                        opacity: isUnlocked ? 1.0 : 0.6,
                        child: Text(
                          widget.badge.name.toUpperCase(),
                          style: pixelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16), // Extra spacing to clear the white strip

                      // Description
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

                      // Close Button
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2d3436), width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, offset: Offset(2, 2))
                            ],
                          ),
                          child: Text(
                            buttonText,
                            style: pixelStyle.copyWith(fontSize: 10),
                          ),
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

// Reusing the StripePainter from your Trainer Card
class StripePainter extends CustomPainter {
  final Color stripeColor;

  StripePainter({required this.stripeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = stripeColor;
    const stripeHeight = 4.0;
    for (double i = 0; i < size.height; i += stripeHeight * 2) {
      canvas.drawRect(Rect.fromLTWH(0, i, size.width, stripeHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}