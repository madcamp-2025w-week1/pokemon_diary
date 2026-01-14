import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 

import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart'; 
import '../services/sound_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  static const double _itemExtent = 64; 
  final ScrollController _scrollController = ScrollController();
  
  // View State
  bool _isCalendarView = false;
  DateTime _focusedMonth = DateTime.now();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Calendar Logic ---
  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset, 1);
    });
    SoundService().playCardSelectSound();
  }

  // [UPDATED] Custom Month/Year Picker
  Future<void> _pickMonth(BuildContext context) async {
    SoundService().playCardSelectSound();
    
    final settings = context.read<SettingsProvider>();
    final pixelText = UiThemeHelper.getPixelFont(
      const TextStyle(fontSize: 12, color: Colors.white),
      isKorean: settings.isKorean
    );

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => _MonthYearPickerDialog(
        initialDate: _focusedMonth,
        pixelText: pixelText,
      ),
    );

    if (picked != null) {
      setState(() {
        _focusedMonth = picked;
      });
      SoundService().playCardSelectSound();
    }
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDay.weekday; 
    final daysBefore = firstWeekday == 7 ? 0 : firstWeekday;
    
    final startOfGrid = firstDay.subtract(Duration(days: daysBefore));
    final endOfGrid = startOfGrid.add(const Duration(days: 41)); 

    List<DateTime> days = [];
    DateTime current = startOfGrid;
    while (current.isBefore(endOfGrid) || current.isAtSameMomentAs(endOfGrid)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    final pokedexProvider = context.watch<PokedexProvider>();
    final settings = context.watch<SettingsProvider>(); 
    
    final diaries = diaryProvider.diaries;

    final pixelText = UiThemeHelper.getPixelFont(
      const TextStyle(
        fontSize: 11,
        color: Color(0xFF2F3A3A),
      ),
      isKorean: settings.isKorean,
    );

    if (diaryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (diaries.isEmpty) {
      return SafeArea(
        child: Container(
          color: const Color(0xFF2B6FD3),
          child: Column(
            children: [
              _buildHeader(pixelText, settings),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildEmptyDetailPanel(settings, pixelText),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }

    if (_selectedIndex >= diaries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIndex = diaries.length - 1);
      });
    }

    final selectedDiary = diaries[_selectedIndex.clamp(0, diaries.length - 1)];

    return SafeArea(
      child: Container(
        color: const Color(0xFF2B6FD3),
        child: Column(
          children: [
            _buildHeader(pixelText, settings),
            const SizedBox(height: 8), 
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    // Top: Detail Panel
                    Expanded(
                      flex: 2, 
                      child: _buildDetailPanel(selectedDiary, pixelText, pokedexProvider, settings),
                    ),
                    const SizedBox(height: 8),
                    
                    // Bottom: List or Calendar
                    Expanded(
                      flex: 3, 
                      child: _isCalendarView 
                          ? _buildCalendarPanel(diaries, pixelText)
                          : _buildListPanel(diaries, pixelText),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextStyle pixelText, SettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12), 
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A6D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0F2142), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF0F2142),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                settings.getText('DIARY_ENTRIES'), 
                style: pixelText.copyWith(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          // View Toggle Button
          GestureDetector(
            onTap: () {
              SoundService().playCardSelectSound();
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCalendarView ? Icons.list : Icons.calendar_today,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isCalendarView ? settings.getText('LIST_VIEW') : settings.getText('CALENDAR_VIEW'),
                    style: pixelText.copyWith(color: Colors.white, fontSize: 9),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPanel(List<Diary> diaries, TextStyle pixelText) {
    final days = _getDaysInMonth(_focusedMonth);
    const gridColor = Color(0xFF1D3E6B);
    const cellColor = Color(0xFFEFF8FA);
    
    final Map<String, int> dateToIndex = {};
    for (int i = 0; i < diaries.length; i++) {
      final dateObj = DateTime.tryParse(diaries[i].date);
      if (dateObj != null) {
        final key = DateFormat('yyyy-MM-dd').format(dateObj);
        if (!dateToIndex.containsKey(key)) {
          dateToIndex[key] = i;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B79DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gridColor, width: 3),
      ),
      child: Column(
        children: [
          // Month Nav
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => _changeMonth(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // [UPDATED] Date Picker Trigger
              GestureDetector(
                onTap: () => _pickMonth(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('yyyy / MM').format(_focusedMonth),
                        style: pixelText.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => _changeMonth(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Day Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
              Text(day, style: pixelText.copyWith(color: Colors.white70, fontSize: 10))
            ).toList(),
          ),
          const SizedBox(height: 4),
          // Grid
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: gridColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final date = days[index];
                  final isCurrentMonth = date.month == _focusedMonth.month;
                  
                  final dateKey = DateFormat('yyyy-MM-dd').format(date);
                  final diaryIndex = dateToIndex[dateKey];
                  final hasEntry = diaryIndex != null;
                  
                  final isSelected = hasEntry && (_selectedIndex == diaryIndex);

                  // Determine Background Color
                  Color bgColor;
                  if (isSelected) {
                    bgColor = const Color(0xFFF2C94C); // Bright Gold (Selected)
                  } else if (hasEntry) {
                    bgColor = const Color(0xFFE5D98C); // Diary Yellow
                  } else if (isCurrentMonth) {
                    bgColor = cellColor; // Default
                  } else {
                    bgColor = Colors.white.withValues(alpha: 0.4); // Outside Month
                  }

                  return GestureDetector(
                    onTap: hasEntry ? () {
                      SoundService().playCardSelectSound();
                      setState(() {
                        _selectedIndex = diaryIndex;
                      });
                    } : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(2),
                        border: (!hasEntry && DateUtils.isSameDay(date, DateTime.now()))
                            ? Border.all(color: const Color(0xFFF2C94C), width: 2)
                            : null
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 2, left: 3,
                            child: Text(
                              "${date.day}",
                              style: pixelText.copyWith(
                                fontSize: 8, 
                                color: (isCurrentMonth || hasEntry) ? Colors.black54 : Colors.black26
                              ),
                            ),
                          ),
                          if (hasEntry)
                             Center(
                               child: Padding(
                                 padding: const EdgeInsets.only(top: 6),
                                 child: _DiaryIcon(
                                   pokemonId: diaries[diaryIndex].pokemonId,
                                   size: 20
                                 ),
                               ),
                             ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPanel(List<Diary> diaries, TextStyle pixelText) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B79DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1D3E6B), width: 3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double bottomPadding = (constraints.maxHeight - _itemExtent).clamp(0.0, double.infinity);

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final index = (notification.metrics.pixels / _itemExtent).round();
                final clamped = index.clamp(0, diaries.length - 1);
                
                if (clamped != _selectedIndex) {
                  setState(() {
                    _selectedIndex = clamped;
                  });
                  SoundService().playCardSelectSound();
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              itemExtent: _itemExtent,
              padding: EdgeInsets.only(bottom: bottomPadding),
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                final diary = diaries[index];
                final isSelected = index == _selectedIndex;
                
                return _DiaryListItem(
                  diary: diary,
                  isSelected: isSelected,
                  pixelText: pixelText,
                  onTap: () {
                    _scrollController.animateTo(
                      index * _itemExtent,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    );
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailPanel(Diary diary, TextStyle pixelText, PokedexProvider pokedex, SettingsProvider settings) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(8), 
      decoration: BoxDecoration(
        color: const Color(0xFFE5D98C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8E7B2C), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFF1D3E6B), offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(10), 
        decoration: BoxDecoration(
          color: const Color(0xFFEFF8FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2F3A3A), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPokemonIcon(diary.pokemonId, 40), 
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${settings.getText('DATE_LABEL')} ${DateHelper.formatShortDateFromString(diary.date)}", 
                    style: pixelText.copyWith(fontSize: 11), 
                  ),
                ),
                _buildSentimentBadge(diary.sentiment, pixelText, settings),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: LinedPaperPainter(lineGap: 20)),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: SingleChildScrollView(
                        child: Text(
                          diary.content, 
                          style: pixelText.copyWith(height: 1.8, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDetailPanel(SettingsProvider settings, TextStyle pixelText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5D98C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8E7B2C), width: 3),
        boxShadow: const [BoxShadow(color: Color(0xFF1D3E6B), offset: Offset(2, 2), blurRadius: 0)],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF8FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2F3A3A), width: 2),
        ),
        child: Center(
          child: Text(
            settings.getText('NO_DIARIES'), 
            textAlign: TextAlign.center,
            style: pixelText.copyWith(height: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonIcon(int pokemonId, double size) {
    return _DiaryIcon(pokemonId: pokemonId, size:size);
  }

  Widget _buildSentimentBadge(String sentiment, TextStyle pixelText, SettingsProvider settings) {
    final localizedSentiment = settings.getText(sentiment.toUpperCase());
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: UiThemeHelper.getSentimentColor(sentiment),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2F3A3A), width: 2),
      ),
      child: Text(
        localizedSentiment.toUpperCase(), 
        style: pixelText.copyWith(fontSize: 8, color: Colors.white)
      ),
    );
  }
}

class _DiaryListItem extends StatelessWidget {
  final Diary diary;
  final bool isSelected;
  final TextStyle pixelText;
  final VoidCallback onTap;

  const _DiaryListItem({
    required this.diary,
    required this.isSelected,
    required this.pixelText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateHelper.formatShortDateFromString(diary.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6), 
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: isSelected ? 1 : 0,
              child: const Icon(Icons.play_arrow, color: Color(0xFFE5D98C), size: 16),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5D98C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2F3A3A) : const Color(0xFF8E7B2C),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF1D3E6B), offset: Offset(1, 1), blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD8BF5B),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          _DiaryIcon(pokemonId: diary.pokemonId, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateLabel,
                              style: pixelText.copyWith(fontSize: 8),
                            ),
                          ),
                          Transform.scale(scale: 0.8, child: _SentimentDot(sentiment: diary.sentiment)),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2E8B7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        _titleSnippet(diary.content),
                        style: pixelText.copyWith(fontSize: 9),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  String _titleSnippet(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 'ENTRY';
    return trimmed.length > 24 ? '${trimmed.substring(0, 24)}...' : trimmed;
  }
}

class _DiaryIcon extends StatelessWidget {
  final int pokemonId;
  final double size;

  const _DiaryIcon({required this.pokemonId, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();
    
    final pokemon = pokedex.allPokemon.firstWhere(
      (p) => p.id == pokemonId, 
      orElse: () => Pokemon.empty()
    );

    final iconUrl = (pokemon.id != 0) 
        ? pokemon.iconSpriteUrl 
        : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/$pokemonId.png';

    return Image.network(
      iconUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(width: size, height: size);
      },
    );
  }
}

class _SentimentDot extends StatelessWidget {
  final String sentiment;

  const _SentimentDot({required this.sentiment});

  @override
  Widget build(BuildContext context) {
    final color = UiThemeHelper.getSentimentColor(sentiment);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2F3A3A), width: 1.5),
      ),
    );
  }
}

// [ADDED] Custom Year/Month Picker Widget
class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final TextStyle pixelText;

  const _MonthYearPickerDialog({required this.initialDate, required this.pixelText});

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _currentYear;

  @override
  void initState() {
    super.initState();
    _currentYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A6D), // Header Blue
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0F2142), width: 3),
          boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(4, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    SoundService().playCardSelectSound();
                    setState(() => _currentYear--);
                  },
                ),
                Text(
                  "$_currentYear",
                  style: widget.pixelText.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    SoundService().playCardSelectSound();
                    setState(() => _currentYear++);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Months Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(12, (index) {
                final monthIndex = index + 1;
                // Simple 3-letter month abbreviations
                final date = DateTime(2000, monthIndex, 1);
                final monthName = DateFormat('MMM').format(date).toUpperCase();
                
                return GestureDetector(
                  onTap: () => Navigator.pop(context, DateTime(_currentYear, monthIndex, 1)),
                  child: Container(
                    width: 64,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B79DB), // Button Blue
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      monthName,
                      style: widget.pixelText.copyWith(fontSize: 10, color: Colors.white),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}