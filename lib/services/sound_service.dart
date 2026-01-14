import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  Future<void>? _initFuture;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _tabSfxPlayer = AudioPlayer();
  final AudioPlayer _cardSfxPlayer = AudioPlayer();
  final AudioPlayer _gachaButtonPlayer = AudioPlayer();
  final AudioPlayer _pokeballSpinPlayer = AudioPlayer();
  final AudioPlayer _electricShockPlayer = AudioPlayer();
  final AudioPlayer _pokemonOutPlayer = AudioPlayer();

  // Settings State
  double _bgmVolume = 0.4;
  final double _bgmLoweredVolume = 0.15;
  double _sfxVolume = 0.1;
  String? _currentTrack;

// 1. 기본 트랙 상수 정의
  static const String defaultTrack = 'Pallete Town.mp3';

// 2. 사용 가능한 BGM 파일명 리스트
final List<String> bgmTracks = [
    'Pallete Town.mp3',
    'Pokémon Center.mp3',
    'Pewter City.mp3',
    'Pokémon Gym.mp3',
    'Vermilion City.mp3',
    'The Sea.mp3',
    'Cerulean City.mp3',
    'Cinnabar Island.mp3',
    'Sevii Islands.mp3',
    'Epilogue.mp3'
  ];

  // 3. BGM 폴더 기본 경로
  static const String _bgmBasePath = 'sounds/bgm/';

  Duration _pokeballSpinDuration = const Duration(milliseconds: 1200);
  Duration _electricShockDuration = const Duration(milliseconds: 900);
  Duration _pokemonOutDuration = const Duration(milliseconds: 1200);
  Duration _gachaButtonDuration = const Duration(milliseconds: 600);

  Duration get pokeballSpinDuration => _pokeballSpinDuration;
  Duration get electricShockDuration => _electricShockDuration;
  Duration get pokemonOutDuration => _pokemonOutDuration;
  Duration get gachaButtonDuration => _gachaButtonDuration;

  Future<void> init() {
    _initFuture ??= _initInternal();
    return _initFuture!;
  }

  Future<void> _initInternal() async {
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
      ),
    ));

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

    await _tabSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _tabSfxPlayer.setSource(AssetSource('sounds/sfx_card_select.wav'));

    await _cardSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _cardSfxPlayer.setSource(AssetSource('sounds/sfx_card_select.wav'));

    await _gachaButtonPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _gachaButtonPlayer.setSource(AssetSource('sounds/sfx_gacha_button.wav'));
    _gachaButtonDuration =
        await _gachaButtonPlayer.getDuration() ?? _gachaButtonDuration;

    await _pokeballSpinPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _pokeballSpinPlayer.setSource(AssetSource('sounds/sfx_pokeball_spin.wav'));
    _pokeballSpinDuration =
        await _pokeballSpinPlayer.getDuration() ?? _pokeballSpinDuration;

    await _electricShockPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _electricShockPlayer.setSource(AssetSource('sounds/sfx_electric_shock.wav'));
    _electricShockDuration =
        await _electricShockPlayer.getDuration() ?? _electricShockDuration;

    await _pokemonOutPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _pokemonOutPlayer.setSource(AssetSource('sounds/sfx_pokemon_out.wav'));
    _pokemonOutDuration =
        await _pokemonOutPlayer.getDuration() ?? _pokemonOutDuration;
  }

  // --- Volume Control ---
  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(_bgmVolume);
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    // Apply to all SFX players
    await _tabSfxPlayer.setVolume(_sfxVolume);
    await _cardSfxPlayer.setVolume(_sfxVolume);
    await _gachaButtonPlayer.setVolume(_sfxVolume);
    await _pokeballSpinPlayer.setVolume(_sfxVolume);
    await _electricShockPlayer.setVolume(_sfxVolume);
    await _pokemonOutPlayer.setVolume(_sfxVolume);
  }

  Future<void> duckBgm() async {
    // FIX: If volume is off (or very low), don't set it to the fixed 0.15
    if (_bgmVolume <= 0) return;

    // Ensure we don't make it LOUDER if the user set volume to 0.1
    // We take the smaller of the two values: the 'duck' target or the current user setting.
    double targetVolume = _bgmLoweredVolume;
    if (_bgmVolume < targetVolume) {
      targetVolume = _bgmVolume;
    }

    await _bgmPlayer.setVolume(targetVolume);
  }

  Future<void> restoreBgm() async {
    await _bgmPlayer.setVolume(_bgmVolume);
  }

  // --- BGM Control ---
Future<void> playBgm(String trackFilename) async {
    try {
      // 1. 전체 경로 생성 (sounds/bgm/Pallet Town.mp3)
      final fullPath = '$_bgmBasePath$trackFilename';

      // 2. 현재 재생 중인 곡과 같으면 무시
      if (_currentTrack == trackFilename && _bgmPlayer.state == PlayerState.playing) {
        return;
      }
      
      _currentTrack = trackFilename; 
      
      await _bgmPlayer.stop();
      // AssetSource는 'assets/'를 자동으로 붙여주므로 'sounds/bgm/...'만 넘김
      await _bgmPlayer.setSource(AssetSource(fullPath));
      await _bgmPlayer.setVolume(_bgmVolume);
      await _bgmPlayer.resume();
    } catch (e) {
      print("Error playing BGM: $e");
      // ★ 에러 발생 시 기본 BGM으로 폴백 시도 (재귀 호출 방지 조건 추가 권장)
      if (trackFilename != defaultTrack) {
        print("Falling back to default track.");
        playBgm(defaultTrack);
      }
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _currentTrack = null; // Reset tracker so it can play again if requested
  }

  Future<void> pauseBgm() async {
    if (_bgmPlayer.state == PlayerState.playing) {
      await _bgmPlayer.pause();
    }
  }

  Future<void> resumeBgm() async {
    if (_bgmPlayer.state == PlayerState.paused) {
      await _bgmPlayer.resume();
    }
  }

  // --- SFX Triggers ---

  Future<void> playCardSelectSound() async {
    await _playSfx(_cardSfxPlayer, 'sounds/sfx_card_select.wav');
  }

  Future<void> playGachaButton() async {
    await init();
    await _playSfx(
      _gachaButtonPlayer,
      'sounds/sfx_gacha_button.wav',
    );
    await Future.delayed(_gachaButtonDuration);
  }

  Future<void> playPokeballSpin() async {
    await _playSfx(
      _pokeballSpinPlayer,
      'sounds/sfx_pokeball_spin.wav',
    );
  }

  Future<void> stopPokeballSpin() async {
    if (_pokeballSpinPlayer.state == PlayerState.playing) {
      await _pokeballSpinPlayer.stop();
    }
  }

  Future<void> playElectricShock() async {
    await _playSfx(
      _electricShockPlayer,
      'sounds/sfx_electric_shock.wav',
    );
  }

  Future<void> playPokemonOut() async {
    await _playSfx(
      _pokemonOutPlayer,
      'sounds/sfx_pokemon_out.wav',
    );
  }

  Future<void> playTabSound() async {
    await _playSfx(_tabSfxPlayer, 'sounds/sfx_card_select.wav');
  }

  Future<void> _playSfx(AudioPlayer player, String asset) async {
    // 1. Restore the Mute Check
    if (_sfxVolume <= 0) return; 

    // 2. Stop if currently playing (Rapid fire support)
    if (player.state == PlayerState.playing) {
      await player.stop();
    }

    // 3. Just Play - Do not wait for completion
    // We await the 'start' of playback, but not the 'end' of the file.
    await player.play(AssetSource(asset));
  }
}
