import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/sound_service.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'screens.dart';

class TrainerCardPage extends StatefulWidget {
  const TrainerCardPage({super.key});

  @override
  State<TrainerCardPage> createState() => _TrainerCardPageState();
}

class _TrainerCardPageState extends State<TrainerCardPage> {

  @override
  Widget build(BuildContext context) {
    final trainerProvider = context.watch<TrainerProvider>();
    final settings = context.watch<SettingsProvider>(); // LOCALIZATION

    String displayDebut = settings.getText('LOADING');
    if (trainerProvider.debutDate != "???" && trainerProvider.debutDate != "NOT STARTED") {
      try {
        final date = DateTime.parse(trainerProvider.debutDate);
        displayDebut = DateHelper.formatFullDate(date);
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
          badges: trainerProvider.badges, 
          settings: settings, // PASS SETTINGS
          onEditName: () => _showEditNameDialog(context, trainerProvider, settings),
          onEditGender: () => _showGenderDialog(context, trainerProvider, settings),
          onSave: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, TrainerProvider provider, SettingsProvider settings) {
    TextEditingController controller = TextEditingController(text: provider.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.getText('CHANGE_NAME')),
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

  void _showGenderDialog(BuildContext context, TrainerProvider provider, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(settings.getText('SELECT_GENDER')),
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
  final SettingsProvider settings; // ADDED
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
    required this.settings,
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
            Container(color: cardBgLight),
            Column(
              children: [
                const SizedBox(height: 48),
                Container(height: 124, width: double.infinity, color: Colors.white.withOpacity(0.9)),
              ],
            ),
            Positioned.fill(
              child: CustomPaint(painter: StripePainter(stripeColor: Colors.black.withOpacity(0.05))),
            ),
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
                            settings.getText('TRAINER_CARD'), // Localized
                            style: pixelStyle.copyWith(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(settings.getText('NAME'), trainerName, pixelStyle, onTap: onEditName),
                                const SizedBox(height: 4),
                                _buildInfoRow(settings.getText('GENDER'), gender, pixelStyle, onTap: onEditGender),
                                const SizedBox(height: 4),
                                Text("${settings.getText('DEBUT')}: $debutDate", style: pixelStyle),
                                const SizedBox(height: 4),
                                Text("${settings.getText('STREAK_LABEL')}: $streak ${settings.getText('DAYS')}", style: pixelStyle),
                              ],
                            ),
                          ),
                          Container(
                            width: 72, height: 80,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFa8dcb2).withOpacity(0.8),
                              border: Border.all(color: borderDark, width: 2),
                            ),
                            child: Image.asset(imagePath, fit: BoxFit.contain),
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
                            Text(settings.getText('BADGES'), style: pixelStyle.copyWith(color: Colors.white, fontSize: 10)),
                            Container(height: 2, color: Colors.white.withOpacity(0.5), margin: const EdgeInsets.only(bottom: 4)),
                            
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 8, runSpacing: 4,
                                children: badges.map((badge) {
                                  return GestureDetector(
                                    onTap: () {
                                      SoundService().playCardSelectSound();
                                      showDialog(
                                        context: context,
                                        builder: (context) => BadgeUnlockDialog(
                                          badge: badge,
                                          onClose: () => Navigator.pop(context),
                                        ),
                                      );
                                    },
                                    child: Opacity(
                                      opacity: badge.isUnlocked ? 1.0 : 0.3,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: badge.isUnlocked ? BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 6)]
                                        ) : null,
                                        child: Icon(badge.icon, color: badge.isUnlocked ? Colors.white : Colors.black, size: 16),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  SoundService().playCardSelectSound();
                                  onSave();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: borderDark),
                                    boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2))]
                                  ),
                                  child: Text(settings.getText('SAVE_CLOSE'), style: pixelStyle.copyWith(fontSize: 10)),
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