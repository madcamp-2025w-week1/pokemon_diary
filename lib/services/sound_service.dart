import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _tabSfxPlayer = AudioPlayer();
  final AudioPlayer _cardSfxPlayer = AudioPlayer();

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
    await _bgmPlayer.setVolume(0.4);

    await _tabSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _tabSfxPlayer.setVolume(1.0);
    await _tabSfxPlayer.setSource(AssetSource('sounds/sfx_card_select.wav'));

    await _cardSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _cardSfxPlayer.setVolume(1.0);
    await _cardSfxPlayer.setSource(AssetSource('sounds/sfx_card_select.wav'));
  }

  Future<void> playBgm() async {
    if (_bgmPlayer.state == PlayerState.playing) return;
    await _bgmPlayer.play(AssetSource('sounds/bgm_main_8bit.mp3'));
  }

  Future<void> playTabSound() async {
    if (_tabSfxPlayer.state == PlayerState.playing) {
      await _tabSfxPlayer.stop();
    }
    await _tabSfxPlayer.play(AssetSource('sounds/sfx_card_select.wav'));
  }

  Future<void> playCardSelectSound() async {
    if (_cardSfxPlayer.state == PlayerState.playing) {
      await _cardSfxPlayer.stop();
    }
    await _cardSfxPlayer.play(AssetSource('sounds/sfx_card_select.wav'));
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

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }
}
