import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  Future<void> init() async {
    // ★ [핵심] 오디오 모드 설정: 사운드가 겹쳐도 BGM이 멈추지 않게 함 (Mixing)
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game, // 게임용 설정
        audioFocus: AndroidAudioFocus.none, // ★ 중요: 포커스를 뺏지 않음 (병렬 재생)
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient, // ★ 중요: 다른 소리와 섞임
      ),
    ));

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.4); 
  }

  Future<void> playBgm() async {
    if (_bgmPlayer.state == PlayerState.playing) return;
    await _bgmPlayer.play(AssetSource('sounds/bgm_main_8bit.mp3'));
  }

  // ★ [수정] 탭 전환 효과음
  Future<void> playTabSound() async {
    final sfxPlayer = AudioPlayer();
    // 효과음 볼륨을 BGM보다 크게 설정해서 뚫고 나오게 함
    await sfxPlayer.setVolume(1.0); 
    
    // ★ 중요: MP3 대신 WAV 사용 권장! (파일명을 wav로 바꿨다고 가정하거나, mp3라도 최대한 빠르게)
    // 반응속도 최우선 모드 (PlayerMode.lowLatency)
    await sfxPlayer.play(AssetSource('sounds/tab_switching.mp3'), mode: PlayerMode.lowLatency);
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