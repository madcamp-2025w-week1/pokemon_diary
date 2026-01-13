import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // ScrollDirection 사용을 위해 추가
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/screens.dart';
import 'providers/providers.dart';
import 'services/sound_service.dart';
import 'utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 1;
  late final PageController _pageController;

  static const Color gbBody = Color(0xFFD9D9D9);
  static const Color gbBorder = Color(0xFF333333);
  static const Color gbScreen = Color(0xFFFFFFFF);
  static const Color gbBtnIdle = Color(0xFFC0C0C0);
  static const Color gbBtnPress = Color(0xFF8E8E8E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _pageController = PageController(initialPage: _currentIndex);

    SoundService().init().then((_) {
      // Check if widget is still on screen
      if (mounted) {
        // 1. Get the saved track from SettingsProvider
        final settings = context.read<SettingsProvider>();
        
        // 2. Pass it to playBgm
        SoundService().playBgm(settings.bgmTrack);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        SoundService().pauseBgm();
        break;
      case AppLifecycleState.resumed:
        SoundService().resumeBgm();
        break;
      case AppLifecycleState.detached:
        SoundService().stopBgm();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH SETTINGS PROVIDER
    final settings = context.watch<SettingsProvider>();

    final pixelStyle = GoogleFonts.pressStart2p(
      fontSize: 10,
      color: gbBorder,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: gbScreen,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: gbBody,
            border: Border(bottom: BorderSide(color: gbBorder, width: 4)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leadingWidth: 64,
            leading: _buildTrainerIcon(context),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4F1),
                border: Border.all(color: gbBorder, width: 2),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(6),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF97A7A2),
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                DateHelper.formatFullDate(DateTime.now()).toUpperCase(),
                style: pixelStyle.copyWith(fontSize: 10, letterSpacing: 1),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: gbBorder, size: 24),
                onPressed: () {
                  SoundService().playCardSelectSound();
                  showDialog(
                    context: context,
                    builder: (context) => const SettingsDialog(), 
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      // ★ NotificationListener를 사용하여 스크롤 상태 감지
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // 사용자가 직접 손가락으로 밀고 있을 때만 로직이 작동하게 함
          return false;
        },
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            // ★ [핵심 로직] 사용자가 손가락으로 드래그 중일 때만 소리 재생 (스와이프 대응)
            // _pageController.position.userScrollDirection이 idle이 아니면 '스와이프' 중인 것임
            if (_pageController.position.userScrollDirection != ScrollDirection.idle) {
              if (_currentIndex != index) {
                SoundService().playTabSound();
              }
            }
            setState(() => _currentIndex = index);
          },
          children: const [
            _KeepAliveWrapper(child: DiaryScreen()),
            _KeepAliveWrapper(child: DraftScreen()),
            _KeepAliveWrapper(child: PokedexScreen()),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 95,
          decoration: const BoxDecoration(
            color: gbBody,
            border: Border(top: BorderSide(color: gbBorder, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // 2. USE LOCALIZED STRINGS FROM SETTINGS PROVIDER
              _buildRetroTab(0, Icons.menu_book, settings.getText('DIARY'), pixelStyle),
              const SizedBox(width: 10),
              _buildRetroTab(1, Icons.edit_note, settings.getText('DRAFT'), pixelStyle),
              const SizedBox(width: 10),
              _buildRetroTab(2, Icons.grid_view, settings.getText('POKEDEX'), pixelStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainerIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Center(
        child: GestureDetector(
          onTap: () {
            SoundService().playCardSelectSound();
            showDialog(
              context: context,
              builder: (context) => const TrainerCardPage(),
            );
          },
          child: Consumer<TrainerProvider>(
            builder: (context, trainer, child) {
              final iconPath = trainer.gender == "MALE"
                  ? 'assets/images/trainer_card_icon_boy.png'
                  : 'assets/images/trainer_card_icon_girl.png';
              return Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: gbBorder, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset(iconPath, width: 32, height: 26, fit: BoxFit.cover),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRetroTab(int index, IconData icon, String label, TextStyle style) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // ★ [핵심 로직] 버튼을 눌렀을 때는 즉시 소리 재생 (버튼 클릭 대응)
          // index가 현재와 다를 때만 재생하여 중복 방지
          if (_currentIndex != index) {
            SoundService().playTabSound();
          }

          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: isSelected ? gbBtnPress : gbBtnIdle,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: gbBorder, width: 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(1, 1))
                  ]
                : [
                    const BoxShadow(color: gbBorder, offset: Offset(3, 3), blurRadius: 0)
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : gbBorder,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: style.copyWith(
                  fontSize: 9,
                  color: isSelected ? Colors.white : gbBorder,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});
  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin<_KeepAliveWrapper> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
  @override
  bool get wantKeepAlive => true;
}