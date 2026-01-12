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
      duration: const Duration(milliseconds: 600),
    );
    
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFf8c291), // Gold/Orange border
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
              color: const Color(0xFFfad390), // Lighter inner
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFe58e26), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFe58e26),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                  child: Text(
                    "ACHIEVEMENT!",
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFe58e26), width: 3),
                    boxShadow: const [
                       BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))
                    ]
                  ),
                  child: Icon(
                    widget.badge.icon,
                    size: 40,
                    color: const Color(0xFFe58e26),
                  ),
                ),

                const SizedBox(height: 16),

                // Badge Name
                Text(
                  widget.badge.name.toUpperCase(),
                  style: pixelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.badge.description,
                    style: pixelStyle.copyWith(fontSize: 10, color: Colors.black87),
                    textAlign: TextAlign.center,
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
                      "AWESOME!",
                      style: pixelStyle.copyWith(fontSize: 10),
                    ),
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