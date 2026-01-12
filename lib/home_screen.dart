import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 필수 패키지
import 'package:pokemon_diary/providers/trainer_provider.dart';
import 'package:provider/provider.dart';

import 'screens/screens.dart';
import 'screens/trainer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  late final PageController _pageController;

  static const Color gbBody = Color(0xFFD9D9D9);   // 메인 본체 회색
  static const Color gbBorder = Color(0xFF333333); // 아주 진한 테두리
  static const Color gbScreen = Color(0xFFFFFFFF); // 게임보이 스크린 녹색 (배경용)
  static const Color gbBtnIdle = Color(0xFFC0C0C0); // 기본 버튼 회색
  static const Color gbBtnPress = Color(0xFF8E8E8E); // 눌린 버튼 회색

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pixelStyle = GoogleFonts.pressStart2p(
      fontSize: 10,
      color: gbBorder,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: gbScreen, // 전체 배경을 게임보이 스크린 색상으로 변경
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: gbBody, // 헤더를 본체 회색으로
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
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [
          _KeepAliveWrapper(child: Tab2Diary()),
          _KeepAliveWrapper(child: Tab1Draft()),
          _KeepAliveWrapper(child: Tab3Pokedex()),
        ],
      ),
      bottomNavigationBar: Container(
        height: 95,
        decoration: const BoxDecoration(
          color: gbBody, // 푸터를 본체 회색으로
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
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            // ★ 선택 시 더 진한 회색(gbBtnPress), 아닐 시 기본 회색(gbBtnIdle)
            color: isSelected ? gbBtnPress : gbBtnIdle,
            borderRadius: BorderRadius.circular(4), // 조금 더 각진 느낌으로 수정
            border: Border.all(color: gbBorder, width: 2),
            boxShadow: isSelected
                ? [
                    // 눌렸을 때는 안쪽으로 들어간 느낌을 위해 그림자 방향 반전 (내부 그림자 느낌)
                    BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(1, 1))
                  ]
                : [
                    // 평소에는 오른쪽 아래로 강한 검은색 그림자 (입체감)
                    const BoxShadow(color: gbBorder, offset: Offset(3, 3), blurRadius: 0)
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                color: isSelected ? Colors.white : gbBorder, // 선택 시 아이콘 색상 변경
                size: 20
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
    const weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']; // 레트로 감성 3글자 약자
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

    final String dayName = weekdays[date.weekday % 7]; // 요일 추출
    final String monthName = months[date.month - 1];
    
    // 출력 형태: "SUN, 11 JAN 2026"
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
