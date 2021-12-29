import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rythm/Screens/Player/player_screen.dart';

class AudioPlayerServiceImpl extends BaseAudioHandler
    with QueueHandler, SeekHandler
    implements AudioPlayerHandler {
  late AudioPlayer _player = AudioPlayer();

  // The most common callbacks:
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> skipToQueueItem(int index) async {}

  @override
  Future<void> moveQueueItem(int currentIndex, int newIndex) {
    // TODO: implement moveQueueItem
    throw UnimplementedError();
  }

  @override
  // TODO: implement queueState
  Stream<QueueState> get queueState => throw UnimplementedError();

  @override
  Future<void> setVolume(double volume) {
    // TODO: implement setVolume
    throw UnimplementedError();
  }

  @override
  // TODO: implement speed
  ValueStream<double> get speed => throw UnimplementedError();

  @override
  // TODO: implement volume
  ValueStream<double> get volume => throw UnimplementedError();
}
