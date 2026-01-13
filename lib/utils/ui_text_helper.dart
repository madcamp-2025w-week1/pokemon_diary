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

    // --- BADGE NAMES ---
    'BADGE_BOULDER_NAME': {'en': 'Boulder Badge', 'ko': '회색배지'},
    'BADGE_CASCADE_NAME': {'en': 'Cascade Badge', 'ko': '블루배지'},
    'BADGE_THUNDER_NAME': {'en': 'Thunder Badge', 'ko': '오렌지배지'},
    'BADGE_RAINBOW_NAME': {'en': 'Rainbow Badge', 'ko': '무지개배지'},
    'BADGE_SOUL_NAME': {'en': 'Soul Badge', 'ko': '핑크배지'},
    'BADGE_MARSH_NAME': {'en': 'Marsh Badge', 'ko': '골드배지'},
    'BADGE_VOLCANO_NAME': {'en': 'Volcano Badge', 'ko': '진홍색배지'},
    'BADGE_EARTH_NAME': {'en': 'Earth Badge', 'ko': '그린배지'},

    // --- BADGE DESCRIPTIONS ---
    'BADGE_BOULDER_DESC': {'en': 'Log entries on 7 different days', 'ko': '7일 동안 일기 작성'},
    'BADGE_CASCADE_DESC': {'en': 'Log Joy, Sad, Angry, and Calm', 'ko': '기쁨, 슬픔, 화남, 평온 모두 기록'},
    'BADGE_THUNDER_DESC': {'en': '3-day streak of High Energy (Joy)', 'ko': '3일 연속 기쁨 기록'},
    'BADGE_RAINBOW_DESC': {'en': 'Catch 10 unique Pokemon types', 'ko': '10가지 다른 타입 포켓몬 수집'},
    'BADGE_SOUL_DESC': {'en': 'Write a long entry (>500 chars)', 'ko': '500자 이상의 긴 일기 작성'},
    'BADGE_MARSH_DESC': {'en': 'Achieve a 30-day writing streak', 'ko': '30일 연속 일기 작성 달성'},
    'BADGE_VOLCANO_DESC': {'en': 'Log 5 Angry entries', 'ko': '화남 일기 5회 작성'},
    'BADGE_EARTH_DESC': {'en': 'Log 50 total entries', 'ko': '총 일기 50회 작성'},

    // --- GENDER ---
    'MALE': {'en': 'MALE', 'ko': '남성'},
    'FEMALE': {'en': 'FEMALE', 'ko': '여성'},

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