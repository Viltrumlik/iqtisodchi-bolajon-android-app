import 'package:audioplayers/audioplayers.dart';

/// Singleton that plays short sound effects from bundled assets.
class SoundService {
  static final SoundService _i = SoundService._();
  factory SoundService() => _i;
  SoundService._();

  final AudioPlayer _player = AudioPlayer();
  bool _muted = false;

  bool get muted => _muted;
  void toggleMute() => _muted = !_muted;

  Future<void> correct()   => _play('sounds/correct.wav');
  Future<void> wrong()     => _play('sounds/wrong.wav');
  Future<void> purchase()  => _play('sounds/purchase.wav');
  Future<void> celebrate() => _play('sounds/celebrate.wav');
  Future<void> tick()      => _play('sounds/tick.wav');

  Future<void> _play(String asset) async {
    if (_muted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {}
  }
}
