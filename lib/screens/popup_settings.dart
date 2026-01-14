import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Removed
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../services/sound_service.dart';
import '../utils/utils.dart'; // For UiThemeHelper

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    final pixelStyle = UiThemeHelper.getPixelFont(
      const TextStyle(
        fontSize: 10,
        color: Color(0xFF2d3436),
      ),
      isKorean: settings.isKorean,
    );

    const Color mainColor = Color(0xFF63c7c8); 
    const Color borderColor = Color(0xFF286a6b);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFe0f2f1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    settings.getText('SETTINGS'),
                    style: pixelStyle.copyWith(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 1. Language Section
              Text(settings.getText('LANGUAGE'), style: pixelStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLangOption(context, settings, 'ENGLISH', 'en'),
                  const SizedBox(width: 12),
                  _buildLangOption(context, settings, '한국어', 'ko'),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(color: borderColor, thickness: 1),
              const SizedBox(height: 16),

              // 2. Art Style Section
              Text(settings.getText('ART_STYLE'), style: pixelStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStyleOption(
                    context, 
                    settings, 
                    settings.getText('MODERN'), 
                    false, // isRetro = false
                  ),
                  const SizedBox(width: 12),
                  _buildStyleOption(
                    context, 
                    settings, 
                    settings.getText('RETRO'), 
                    true, // isRetro = true
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: borderColor, thickness: 1),
              const SizedBox(height: 16),

              // 3. Sound Section
              Text(settings.getText('SOUND'), style: pixelStyle),
              const SizedBox(height: 16),
              
              // BGM Slider
              _buildSliderRow(
                settings.getText('BGM_VOLUME'), 
                settings.bgmVolume, 
                (val) => settings.setBgmVolume(val),
                pixelStyle
              ),
              
              // SFX Slider
              _buildSliderRow(
                settings.getText('SFX_VOLUME'), 
                settings.sfxVolume, 
                (val) => settings.setSfxVolume(val),
                pixelStyle
              ),

              const SizedBox(height: 12),
              
              // BGM Selector
Text(settings.getText('TRACK'), style: pixelStyle.copyWith(fontSize: 8)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    // 현재 선택된 값 (SettingsProvider의 _bgmTrack)
                    value: settings.bgmTrack,
                    isExpanded: true,
                    style: pixelStyle.copyWith(fontSize: 8, color: Colors.black),
                    dropdownColor: Colors.white,
                    // ★ SoundService의 bgmTracks 리스트를 맵핑
                    items: SoundService().bgmTracks.map((trackFilename) {
                      // UI 표시용 이름: 확장자 제거 (.mp3)
                      final displayName = trackFilename.replaceAll('.mp3', '');
                      
                      return DropdownMenuItem(
                        value: trackFilename, // 실제 값은 파일명 전체 (확장자 포함)
                        child: Text(
                          displayName, 
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        settings.setBgmTrack(val);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Close Button
              Center(
                child: GestureDetector(
                  onTap: () {
                     SoundService().playCardSelectSound();
                     Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2,2))],
                    ),
                    child: Text(settings.getText('CLOSE'), style: pixelStyle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangOption(BuildContext context, SettingsProvider settings, String label, String code) {
    final isSelected = settings.languageCode == code;
    final color = isSelected ? const Color(0xFF286a6b) : Colors.grey[400]!;
    
    // [Fix] Hardcode font choice based on the button's language code,
    // instead of the global app setting.
    // 'ko' button -> uses Korean font (isKorean: true)
    // 'en' button -> uses English font (isKorean: false)
    final useKoreanFont = (code == 'ko');

    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService().playCardSelectSound();
          settings.setLanguage(code);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isSelected ? color : Colors.grey),
          ),
          child: Center(
            child: Text(
              label,
              style: UiThemeHelper.getPixelFont(
                TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                // CHANGED: Use the local flag instead of settings.isKorean
                isKorean: useKoreanFont, 
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleOption(BuildContext context, SettingsProvider settings, String label, bool isRetroOption) {
    final isSelected = settings.isRetroArt == isRetroOption;
    final color = isSelected ? const Color(0xFF286a6b) : Colors.grey[400]!;
    
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          SoundService().playCardSelectSound();
          
          await settings.setRetroArt(isRetroOption);
          
          if (context.mounted) {
            await context.read<PokedexProvider>().loadPokedex(
              isRetro: isRetroOption,
              forceRefresh: true,
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isSelected ? color : Colors.grey),
          ),
          child: Center(
            child: Text(
              label,
              style: UiThemeHelper.getPixelFont(
                TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                isKorean: settings.isKorean,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, Function(double) onChanged, TextStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: style.copyWith(fontSize: 8)),
            Text("${(value * 100).toInt()}%", style: style.copyWith(fontSize: 8)),
          ],
        ),
        SizedBox(
          height: 30,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF286a6b),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFFd63031),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}