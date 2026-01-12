import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokemon_diary/providers/trainer_provider.dart';
import 'package:provider/provider.dart';

import 'screens/screens.dart';
import 'screens/trainer_card.dart';
import 'services/sound_service.dart'; // 사운드 서비스 import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ★ 1. Mixin 추가 (WidgetsBindingObserver)
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
    // ★ 2. 감시자 등록
    WidgetsBinding.instance.addObserver(this);
    
    _pageController = PageController(initialPage: _currentIndex);

    // BGM 시작
    SoundService().init().then((_) {
      SoundService().playBgm();
    });
  }

  @override
  void dispose() {
    // ★ 3. 감시자 해제 (메모리 누수 방지)
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  // ★ 4. 앱 생명주기 변화 감지 (핵심 로직)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
        // 앱이 백그라운드로 갔을 때 (홈 화면 등) -> 음악 일시 정지
        SoundService().pauseBgm();
        break;
      case AppLifecycleState.resumed:
        // 앱이 다시 포커스를 잡았을 때 -> 음악 이어서 재생
        SoundService().resumeBgm();
        break;
      case AppLifecycleState.detached:
        // 앱이 완전히 종료될 때 -> 정지
        SoundService().stopBgm();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _formatDate(DateTime.now()).toUpperCase(),
                style: pixelStyle.copyWith(fontSize: 12, letterSpacing: 1),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: gbBorder, size: 24),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          // ★ [핵심 수정] 페이지가 실제로 바뀌는 순간 소리 재생!
          // 스와이프든 버튼 클릭이든 여기서 다 잡힘.
          if (_currentIndex != index) {
            SoundService().playTabSound();
            setState(() => _currentIndex = index);
          }
        },
        children: const [
          _KeepAliveWrapper(child: Tab2Diary()),
          _KeepAliveWrapper(child: Tab1Draft()),
          _KeepAliveWrapper(child: Tab3Pokedex()),
        ],
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
              _buildRetroTab(0, Icons.menu_book, 'DIARY', pixelStyle),
              const SizedBox(width: 10),
              _buildRetroTab(1, Icons.edit_note, 'DRAFT', pixelStyle),
              const SizedBox(width: 10),
              _buildRetroTab(2, Icons.grid_view, 'POKEDEX', pixelStyle),
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
          onTap: () => showDialog(
            context: context,
            builder: (context) => const TrainerCardPage(),
          ),
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
          // ★ [제거] 여기서 playTabSound()를 호출하지 않음! (중복 방지)
          // animateToPage가 실행되면 PageView의 onPageChanged가 호출되면서 소리가 남.
          
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

  String _formatDate(DateTime date) {
    const weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final String dayName = weekdays[date.weekday % 7];
    final String monthName = months[date.month - 1];
    return "$dayName, ${date.day} $monthName ${date.year}";
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