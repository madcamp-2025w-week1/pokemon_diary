// utils/ui_text.dart
class UiText {
  static const Map<String, Map<String, String>> _localizedValues = {
    // --- Tabs ---
    'DIARY': {'en': 'DIARY', 'ko': '일기'},
    'DRAFT': {'en': 'DRAFT', 'ko': '기록'},
    'POKEDEX': {'en': 'POKEDEX', 'ko': '도감'},
    
    // --- Diary Screen ---
    'DIARY_ENTRIES': {'en': 'DIARY ENTRIES', 'ko': '일기 목록'},
    'NO_DIARIES': {
      'en': 'NO DIARIES YET.\nGO DRAFT YOUR FIRST POKEMON!',
      'ko': '아직 일기가 없습니다.\n첫 포켓몬을 기록해보세요!'
    },
    'DATE_LABEL': {'en': 'Date', 'ko': '날짜'},

    // --- Draft Screen ---
    'SCANNING': {'en': 'SCANNING...', 'ko': '스캔중...'},
    'READY_ANALYZE': {'en': 'READY TO ANALYZE', 'ko': '준비 완료'},
    'GACHA': {'en': 'GACHA!', 'ko': '가챠!'},
    'DRAFT_HINT': {
      'en': 'HOW ARE YOU FEELING TODAY? SHARE YOUR THOUGHTS...',
      'ko': '오늘 기분이 어떠신가요? 이야기를 들려주세요...'
    },
    'WARNING_LENGTH': {
       'en': 'Please write at least 10 characters!',
       'ko': '최소 10글자 이상 작성해주세요!'
    },

    // --- Trainer Card ---
    'TRAINER_CARD': {'en': 'TRAINER CARD', 'ko': '트레이너 카드'},
    'NAME': {'en': 'NAME', 'ko': '이름'},
    'GENDER': {'en': 'GENDER', 'ko': '성별'},
    'DEBUT': {'en': 'DEBUT', 'ko': '시작일'},
    'STREAK_LABEL': {'en': 'STREAK', 'ko': '연속'},
    'DAYS': {'en': 'DAYS', 'ko': '일'},
    'BADGES': {'en': 'BADGES', 'ko': '배지'},
    'SAVE_CLOSE': {'en': 'SAVE/CLOSE', 'ko': '저장/닫기'},
    'CHANGE_NAME': {'en': 'Change Name', 'ko': '이름 변경'},
    'SELECT_GENDER': {'en': 'Select Gender', 'ko': '성별 선택'},

    // --- Pokemon Detail ---
    'HT': {'en': 'HT', 'ko': '키'},
    'WT': {'en': 'WT', 'ko': '몸무게'},
    'DATES_CAUGHT': {'en': 'DATES CAUGHT', 'ko': '만난 날짜들'},
    'NO_DATA': {'en': 'NO DATA', 'ko': '데이터 없음'},

    // --- Badges ---
    'ACHIEVEMENT': {'en': 'ACHIEVEMENT!', 'ko': '업적 달성!'},
    'LOCKED': {'en': 'LOCKED', 'ko': '잠김'},
    'AWESOME': {'en': 'AWESOME!', 'ko': '멋져요!'},
    'KEEP_GOING': {'en': 'KEEP GOING', 'ko': '계속하세요'},

    // --- Common / Settings ---
    'SETTINGS': {'en': 'SETTINGS', 'ko': '설정'},
    'CLOSE': {'en': 'CLOSE', 'ko': '닫기'},
    'LANGUAGE': {'en': 'LANGUAGE', 'ko': '언어'},
    'SOUND': {'en': 'SOUND', 'ko': '사운드'},
    'BGM_VOLUME': {'en': 'BGM VOLUME', 'ko': '배경음'},
    'SFX_VOLUME': {'en': 'SFX VOLUME', 'ko': '효과음'},
    'TRACK': {'en': 'TRACK', 'ko': '트랙'},
    'ART_STYLE': {'en': 'ART STYLE', 'ko': '아트 스타일'},
    'MODERN': {'en': 'MODERN', 'ko': '현대적'},
    'RETRO': {'en': 'RETRO', 'ko': '레트로'},
    'FEAT': {'en': 'FEAT.', 'ko': '함께한 포켓몬:'},
  };

  static String get(String key, String languageCode) {
    return _localizedValues[key]?[languageCode] ?? key;
  }
}