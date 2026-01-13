import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _tabSfxPlayer = AudioPlayer();
  final AudioPlayer _cardSfxPlayer = AudioPlayer();

  // Settings State
  double _bgmVolume = 0.4;
  double _sfxVolume = 0.1;
  String? _currentTrack;

  // Available Tracks
  final List<String> bgmTracks = [
    'sounds/bgm_main_8bit.mp3',
  ];

  Future<void> init() async {
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
  }

  // --- BGM Control ---
  Future<void> playBgm(String trackPath) async {
    try {
      // FIX: Compare against our local variable instead of source.path
      if (_currentTrack == trackPath && _bgmPlayer.state == PlayerState.playing) {
        return;
      }
      
      _currentTrack = trackPath; // Update the tracker
      
      await _bgmPlayer.stop();
      await _bgmPlayer.setSource(AssetSource(trackPath));
      await _bgmPlayer.setVolume(_bgmVolume);
      await _bgmPlayer.resume();
    } catch (e) {
      print("Error playing BGM: $e");
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _currentTrack = null; // Reset tracker so it can play again if requested
  }

  Future<void> pauseBgm() async => await _bgmPlayer.pause();
  Future<void> resumeBgm() async => await _bgmPlayer.resume();

  // --- SFX Triggers ---

  Future<void> playTabSound() async {
    if (_sfxVolume <= 0) return;
    if (_tabSfxPlayer.state == PlayerState.playing) {
      await _tabSfxPlayer.stop();
    }
    await _tabSfxPlayer.resume();
  }

  Future<void> playCardSelectSound() async {
    if (_sfxVolume <= 0) return;
    if (_cardSfxPlayer.state == PlayerState.playing) {
      await _cardSfxPlayer.stop();
    }
    await _cardSfxPlayer.resume();
  }
}
