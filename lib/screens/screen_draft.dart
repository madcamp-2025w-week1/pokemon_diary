import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/diary_provider.dart';
import '../providers/gacha_provider.dart';
import '../providers/trainer_provider.dart';
import '../services/services.dart';
import 'popup_badge.dart';

class Tab1Draft extends StatefulWidget {
  const Tab1Draft({super.key});

  @override
  State<Tab1Draft> createState() => _Tab1DraftState();
}

class _Tab1DraftState extends State<Tab1Draft>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  
  // Only UI controllers remain here
  final TextEditingController _controller = TextEditingController();
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  
  // Editor UI State
  bool _isEditorOpen = false;
  final FocusNode _editorFocusNode = FocusNode();
  BuildContext? _editorContext;
  double _lastMessageHeight = 0;
  bool _wasKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(_blinkController);

    // LOAD DATA ON STARTUP via Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final diaryProvider = context.read<DiaryProvider>();
      final apiService = context.read<PokemonApiService>();
      
      context.read<GachaProvider>().loadTodayEntry(diaryProvider, apiService);
    });

    // Close editor if focus lost
    _editorFocusNode.addListener(() {
      if (!_editorFocusNode.hasFocus && _isEditorOpen && _editorContext != null) {
        Navigator.of(_editorContext!).pop();
      }
    });
  }

  @override
  void didChangeMetrics() {
    // Handle keyboard closing logic for the editor
    final bottomInset = View.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    if (_wasKeyboardVisible && !isKeyboardVisible && _isEditorOpen && _editorContext != null && mounted) {
      Navigator.of(_editorContext!).pop();
    }
    _wasKeyboardVisible = isKeyboardVisible;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _editorFocusNode.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  // --- UI ACTION HANDLERS ---

  void _onGachaPressed() {
    final gachaProvider = context.read<GachaProvider>();
    
    // Start the blink animation UI-side
    _blinkController.repeat(reverse: true);

    gachaProvider.performGacha(
      text: _controller.text,
      diaryProvider: context.read<DiaryProvider>(),
      trainerProvider: context.read<TrainerProvider>(),
      apiService: context.read<PokemonApiService>(),
      onError: (msg) {
         _blinkController.stop();
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(msg), backgroundColor: Colors.redAccent)
         );
      },
    ).then((_) {
      // Cleanup after success
      if (mounted) {
        _blinkController.stop();
        _controller.clear();
        _checkAndShowBadges();
      }
    });
  }

  void _checkAndShowBadges() async {
    final gachaProvider = context.read<GachaProvider>();
    final badges = gachaProvider.pendingBadges;
    
    if (badges.isNotEmpty) {
      for (var badge in badges) {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BadgeUnlockDialog(
            badge: badge,
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      }
      gachaProvider.clearPendingBadges();
    }
  }

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    // LISTEN TO STATE
    final gacha = context.watch<GachaProvider>();

    if (gacha.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const headerHeight = 40.0;
          const statusHeight = 38.0;
          final controlsHeight = (constraints.maxHeight * 0.16).clamp(90.0, 120.0);
          final dpadSize = (controlsHeight * 0.75).clamp(60.0, 90.0);
          final gachaSize = (controlsHeight * 0.95).clamp(80.0, 110.0);

          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD93838),
                boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(4, 4))],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  SizedBox(height: headerHeight, child: _buildDraftHeader()),
                  const SizedBox(height: 10),
                  // PASS STATE TO VISUALS
                  Expanded(flex: 5, child: _buildScreen(gacha)),
                  const SizedBox(height: 12),
                  SizedBox(height: statusHeight, child: _buildStatusLabel(gacha)),
                  const SizedBox(height: 12),
                  // TEXT AREA
                  Expanded(
                    flex: 4,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        _lastMessageHeight = boxConstraints.maxHeight;
                        // Determine text to show (History vs Input)
                        final displayText = (!gacha.isInputMode && gacha.todayDiary != null) 
                            ? gacha.todayDiary!.content 
                            : _controller.text;
                            
                        return _buildMessageArea(gacha.isInputMode, displayText);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: controlsHeight,
                    child: _buildControlsRow(dpadSize, gachaSize, gacha.isInputMode, gacha.isGachaAnimating),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildScreen(GachaProvider gacha) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF355A35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF202020), width: 3),
      ),
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF70A070),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E2B1E), width: 2),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: _buildTopVisual(gacha),
          ),
        ),
      ),
    );
  }

  Widget _buildTopVisual(GachaProvider gacha) {
    // 1. SHOW RESULT
    if (gacha.isResultMode && gacha.currentPokemon != null) {
      return Image.network(
        gacha.currentPokemon!.homeSpriteUrl,
        height: 160,
        fit: BoxFit.contain,
      );
    }

    // 2. SHOW ANIMATION
    if (gacha.isGachaAnimating) {
      if (gacha.showLightning) {
        return Lottie.asset(
          gacha.currentLightningAnim, // Data from Provider
          height: 180,
          fit: BoxFit.contain,
        );
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Pokeball loading animation.json',
            height: 140,
            fit: BoxFit.contain,
          ),
          AnimatedBuilder(
            animation: _blinkAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _blinkAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    // 3. SHOW IDLE
    return Lottie.asset(
      'assets/animations/Pokeball loading animation.json',
      height: 140,
      fit: BoxFit.contain,
      animate: false,
    );
  }

  Widget _buildDraftHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8C2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF202020), width: 2),
        boxShadow: const [BoxShadow(color: Color(0xFF202020), offset: Offset(2, 2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.catching_pokemon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'DRAFT',
            style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(GachaProvider gacha) {
    final label = gacha.isGachaAnimating
        ? 'SCANNING...'
        : (gacha.isResultMode && gacha.currentPokemon != null)
            ? gacha.currentPokemon!.englishName.toUpperCase()
            : 'READY TO ANALYZE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF7FB7E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF202020), width: 2),
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildMessageArea(bool isInputMode, String displayText) {
    if (!isInputMode) {
      return _buildSpeechBubble(displayText);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EFD8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF202020), width: 2),
      ),
      child: GestureDetector(
        onTap: _openFloatingEditor,
        child: AbsorbPointer(
          child: TextField(
            controller: _controller,
            enabled: true,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.pressStart2p(fontSize: 11, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'How are you feeling today? Share your thoughts...'.toUpperCase(),
              hintStyle: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EFD8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF202020), width: 2),
      ),
      child: SingleChildScrollView(
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: GoogleFonts.pressStart2p(fontSize: 11, color: Colors.black87, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildControlsRow(double dpadSize, double gachaSize, bool isInputMode, bool isAnimating) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 10),
          child: _buildDpad(dpadSize),
        ),
        const SizedBox(width: 16),
        _buildGachaButton(gachaSize, isInputMode, isAnimating),
      ],
    );
  }

  Widget _buildDpad(double dpadSize) {
    const padColor = Color(0xFF2B2B2B);
    final barThickness = (dpadSize * 0.33).clamp(20.0, 30.0);
    final centerSize = (dpadSize * 0.22).clamp(16.0, 20.0);

    return SizedBox(
      width: dpadSize,
      height: dpadSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: barThickness,
            height: dpadSize,
            decoration: BoxDecoration(
              color: padColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          Container(
            width: dpadSize,
            height: barThickness,
            decoration: BoxDecoration(
              color: padColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          Container(
            width: centerSize,
            height: centerSize,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGachaButton(double gachaSize, bool isInputMode, bool isAnimating) {
    final isEnabled = isInputMode && !isAnimating;
    final buttonColor = isEnabled ? const Color(0xFFF2C94C) : const Color(0xFFB0B0B0);
    final shadowColor = isEnabled ? Colors.black54 : Colors.black26;
    final fontSize = (gachaSize * 0.14).clamp(10.0, 12.0);

    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: isEnabled ? _onGachaPressed : null,
          child: Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
            width: gachaSize,
            height: gachaSize,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF202020), width: 3),
              boxShadow: [BoxShadow(color: shadowColor, offset: Offset(3, 3))],
            ),
            alignment: Alignment.center,
            child: Text(
              'GACHA!',
              style: GoogleFonts.pressStart2p(fontSize: fontSize, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  // --- FLOATING EDITOR (Mostly unchanged UI logic) ---
  Future<void> _openFloatingEditor() async {
    if (_isEditorOpen) return;
    setState(() => _isEditorOpen = true);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        _editorContext = context;
        final viewInsets = MediaQuery.of(context).viewInsets;
        final maxHeight = MediaQuery.of(context).size.height * 0.7;
        final minHeight = _lastMessageHeight > 0 ? _lastMessageHeight : 220.0;
        final constrainedMax = maxHeight < minHeight ? minHeight : maxHeight;
        
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: viewInsets.bottom + 16),
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight, maxHeight: constrainedMax),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EFD8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF202020), width: 2),
            ),
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                TextField(
                  controller: _controller,
                  autofocus: true,
                  focusNode: _editorFocusNode,
                  maxLines: null,
                  style: GoogleFonts.pressStart2p(fontSize: 11, color: Colors.black87),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8C2A2A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) setState(() { _isEditorOpen = false; _editorContext = null; });
  }
}