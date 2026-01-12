import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokemon_diary/screens/badge_popup.dart'; 
import 'package:provider/provider.dart';
import '../providers/trainer_provider.dart';
import '../models/models.dart'; // Ensure PokemonBadge is exported here

class TrainerCardPage extends StatefulWidget {
  const TrainerCardPage({super.key});

  @override
  State<TrainerCardPage> createState() => _TrainerCardPageState();
}

class _TrainerCardPageState extends State<TrainerCardPage> {

  String _formatDate(DateTime date) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get real-time badge updates
    final trainerProvider = context.watch<TrainerProvider>();

    String displayDebut = "LOADING...";
    if (trainerProvider.debutDate != "???" && trainerProvider.debutDate != "NOT STARTED") {
      try {
        final date = DateTime.parse(trainerProvider.debutDate);
        displayDebut = _formatDate(date);
      } catch (_) {
        displayDebut = trainerProvider.debutDate;
      }
    } else {
      displayDebut = trainerProvider.debutDate;
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: TrainerCardDialog(
          trainerName: trainerProvider.name,
          gender: trainerProvider.gender,
          debutDate: displayDebut,
          streak: trainerProvider.streak,
          // PASS THE REAL BADGES HERE
          badges: trainerProvider.badges, 
          onEditName: () => _showEditNameDialog(context, trainerProvider),
          onEditGender: () => _showGenderDialog(context, trainerProvider),
          onSave: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, TrainerProvider provider) {
    TextEditingController controller = TextEditingController(text: provider.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              provider.updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showGenderDialog(BuildContext context, TrainerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Select Gender"),
        children: [
          SimpleDialogOption(
            onPressed: () {
              provider.updateGender("MALE");
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("MALE"),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              provider.updateGender("FEMALE");
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("FEMALE"),
            ),
          ),
        ],
      ),
    );
  }
}

class TrainerCardDialog extends StatelessWidget {
  final String trainerName;
  final String gender;
  final String debutDate;
  final int streak;
  final List<PokemonBadge> badges; 
  final VoidCallback onEditName;
  final VoidCallback onEditGender;
  final VoidCallback onSave;

  const TrainerCardDialog({
    super.key,
    required this.trainerName,
    required this.gender,
    required this.debutDate,
    required this.streak,
    required this.badges,
    required this.onEditName,
    required this.onEditGender,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final pixelStyle = GoogleFonts.pressStart2p(
      fontSize: 10,
      color: const Color(0xFF2d3436),
      height: 1.4,
    );

    const Color borderLight = Color(0xFF63c7c8);
    const Color borderDark = Color(0xFF286a6b);
    const Color cardBgLight = Color(0xFF86c096);

    final String imagePath = gender == "MALE"
        ? 'assets/images/red.png'
        : 'assets/images/misty.png';

    return Container(
      width: 340,
      height: 280, 
      decoration: BoxDecoration(
        color: borderLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // 1. BASE BACKGROUND
            Container(color: cardBgLight),

            // 2. WHITE STRIP
            Column(
              children: [
                const SizedBox(height: 48),
                Container(
                  height: 124,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),

            // 3. GLOBAL STRIPES
            Positioned.fill(
              child: CustomPaint(
                painter: StripePainter(
                  stripeColor: Colors.black.withOpacity(0.05),
                ),
              ),
            ),

            // 4. CONTENT LAYER
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderDark, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF70a0e0),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black.withOpacity(0.2)),
                          ),
                          child: Text(
                            "TRAINER CARD",
                            style: pixelStyle.copyWith(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced slightly

                    // --- MAIN INFO ROW ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Reduced vertical padding
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow("NAME", trainerName, pixelStyle, onTap: onEditName),
                                const SizedBox(height: 4),
                                _buildInfoRow("GENDER", gender, pixelStyle, onTap: onEditGender),
                                const SizedBox(height: 4),
                                Text("DEBUT: $debutDate", style: pixelStyle),
                                const SizedBox(height: 4),
                                Text("STREAK: $streak DAYS", style: pixelStyle),
                              ],
                            ),
                          ),
                          // Right Avatar
                          Container(
                            width: 72,
                            height: 80, // Slightly shorter to save space
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFa8dcb2).withOpacity(0.8),
                              border: Border.all(color: borderDark, width: 2),
                            ),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Icon(Icons.person, size: 40, color: borderDark),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            // --- BADGES SECTION ---
                            Text("BADGES", style: pixelStyle.copyWith(color: Colors.white, fontSize: 10)),
                            Container(
                              height: 2,
                              color: Colors.white.withOpacity(0.5),
                              margin: const EdgeInsets.only(bottom: 4), // Reduced margin
                            ),
                            
                            // *** COMPACT BADGE DISPLAY ***
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 8, // Tighter spacing
                                runSpacing: 4, // Tighter row spacing
                                children: badges.map((badge) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => BadgeUnlockDialog(
                                          badge: badge,
                                          onClose: () => Navigator.pop(context),
                                        ),
                                      );
                                    },
                                    child: Opacity(
                                      // Keep the card icon dimmed if locked
                                      opacity: badge.isUnlocked ? 1.0 : 0.3,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: badge.isUnlocked ? BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 6)
                                          ]
                                        ) : null,
                                        child: Icon(
                                          badge.icon, 
                                          color: badge.isUnlocked ? Colors.white : Colors.black, 
                                          size: 16
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            
                            const SizedBox(height: 8),

                            // --- FOOTER BUTTON ---
                            Center(
                              child: GestureDetector(
                                onTap: onSave,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: borderDark),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, offset: Offset(2, 2))
                                    ]
                                  ),
                                  child: Text("SAVE/CLOSE", style: pixelStyle.copyWith(fontSize: 10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextStyle style, {VoidCallback? onTap}) {
    return Row(
      children: [
        Text("$label: $value", style: style),
        if (onTap != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onTap,
            child: const Icon(Icons.edit, size: 12, color: Colors.black54),
          )
        ]
      ],
    );
  }
}

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