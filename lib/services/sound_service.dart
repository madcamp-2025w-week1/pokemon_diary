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

  final double _bgmVolume = 0.4;
  final double _bgmDuckVolume = 0.15;

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
    await _bgmPlayer.setVolume(_bgmVolume);

    await _tabSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _tabSfxPlayer.setVolume(1.0);
    await _tabSfxPlayer.setSource(AssetSource('sounds/sfx_card_select.wav'));

    await _cardSfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _cardSfxPlayer.setVolume(1.0);
    await _cardSfxPlayer.setSource(AssetSource('sounds/sfx_card_select.wav'));

    await _gachaButtonPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _gachaButtonPlayer.setVolume(0.5);
    await _gachaButtonPlayer.setSource(AssetSource('sounds/sfx_gacha_button.wav'));
    _gachaButtonDuration =
        await _gachaButtonPlayer.getDuration() ?? _gachaButtonDuration;

    await _pokeballSpinPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _pokeballSpinPlayer.setVolume(0.5);
    await _pokeballSpinPlayer.setSource(AssetSource('sounds/sfx_pokeball_spin.wav'));
    _pokeballSpinDuration =
        await _pokeballSpinPlayer.getDuration() ?? _pokeballSpinDuration;

    await _electricShockPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _electricShockPlayer.setVolume(0.5);
    await _electricShockPlayer.setSource(AssetSource('sounds/sfx_electric_shock.wav'));
    _electricShockDuration =
        await _electricShockPlayer.getDuration() ?? _electricShockDuration;

    await _pokemonOutPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _pokemonOutPlayer.setVolume(0.5);
    await _pokemonOutPlayer.setSource(AssetSource('sounds/sfx_pokemon_out.wav'));
    _pokemonOutDuration =
        await _pokemonOutPlayer.getDuration() ?? _pokemonOutDuration;
  }

  Future<void> playBgm() async {
    if (_bgmPlayer.state == PlayerState.playing) return;
    await _bgmPlayer.play(AssetSource('sounds/bgm_main_8bit.mp3'));
  }

  Future<void> duckBgm() async {
    await _bgmPlayer.setVolume(_bgmDuckVolume);
  }

  Future<void> restoreBgm() async {
    await _bgmPlayer.setVolume(_bgmVolume);
  }

  Future<void> playTabSound() async {
    await _playSfx(_tabSfxPlayer, 'sounds/sfx_card_select.wav');
  }

  Future<void> playCardSelectSound() async {
    await _playSfx(_cardSfxPlayer, 'sounds/sfx_card_select.wav');
  }

  Future<void> playGachaButton() async {
    await init();
    await _playSfx(
      _gachaButtonPlayer,
      'sounds/sfx_gacha_button.wav',
      maxWait: _gachaButtonDuration,
    );
  }

  Future<void> playPokeballSpin() async {
    await _playSfx(
      _pokeballSpinPlayer,
      'sounds/sfx_pokeball_spin.wav',
      maxWait: _pokeballSpinDuration,
    );
  }

  Future<void> playElectricShock() async {
    await _playSfx(
      _electricShockPlayer,
      'sounds/sfx_electric_shock.wav',
      maxWait: _electricShockDuration,
    );
  }

  Future<void> playPokemonOut() async {
    await _playSfx(
      _pokemonOutPlayer,
      'sounds/sfx_pokemon_out.wav',
      maxWait: _pokemonOutDuration,
    );
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

  Future<void> _playSfx(AudioPlayer player, String asset, {Duration? maxWait}) async {
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    await player.play(AssetSource(asset));
    if (maxWait == null) {
      await player.onPlayerComplete.first;
      return;
    }
    await Future.any([
      player.onPlayerComplete.first,
      Future.delayed(maxWait),
    ]);
  }
}
