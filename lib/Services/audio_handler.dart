import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythm/Models/boxes.dart';

// Future<AudioHandler> initAudioService() async {
//   return await AudioService.init(
//     builder: () => MyAudioHandler(),
//     config: AudioServiceConfig(
//       androidNotificationChannelId: 'com.ddwsc.rythm.channel.audio',
//       androidNotificationChannelName: 'Rythm',
//       androidNotificationOngoing: true,
//       androidStopForegroundOnPause: true,
//       androidNotificationIcon: 'drawable/ic_stat_music_note',
//       androidShowNotificationBadge: true,
//       // androidStopForegroundOnPause: Hive.box('settings')
//       // .get('stopServiceOnPause', defaultValue: true) as bool,
//       notificationColor: Colors.grey[900],
//     ),
//   );
// }
Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.ddwsc.rythm.channel.audio',
      androidNotificationChannelName: 'Rythm',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler
    implements AudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
    //getPlaying();
  }

  Future<void> loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  // void _listenToChangesIndex() {
  //   _player.currentIndex.listen((index) {

  //   })
  // }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      mediaItem.add(playlist[index]);
      //print('aaaaa current ${_player.position}');
      // final boxIndex = Boxes.getPlayingIndex();
      // boxIndex.put('myPlayingIndex', boxIndex.get('myPlayingIndex')! + 1);
      // print('aaaaaaaaaaboxindex ${boxIndex.get('myPlayingIndex')}');
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  // rememder tag // Modify by ddwsc
  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    final audioSource = newQueue.map(_createAudioSource);

    //await _playlist.clear();
    if (_playlist.length > 0) {
      await _playlist.removeRange(0, _playlist.length);
    }

    //await _playlist.insertAll(0, audioSource.toList());
    //await _playlist.addAll(audioSource.toList());

    //await _playlist.addAll(_itemsToSources(newQueue));
    await _playlist.addAll(audioSource.toList());
    //await _player.setAudioSource();
    print('------------aaa');
    //print('aaaaa current ${_player.hasPrevious}');

    // //this.queue.value.removeRange(0, queue.value.length);
    queue.value.clear();

    // queue.stream.value.clear();
    // // queue.add(newQueue);
    // //print('aaaaa queue ${queue.value.length}');
    final _newQueue = queue.value..addAll(newQueue);
    queue.add(_newQueue);
    queue.distinct();

    // _player.currentIndexStream.first
    //     .then((value) => print('aaaaaaaaaa ${value}'));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    _playlist.add(audioSource);

    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url']),
      tag: mediaItem,
    );
  }

  AudioSource _itemToSource(MediaItem mediaItem) {
    AudioSource _audioSource;
    if (mediaItem.artUri.toString().startsWith('file:')) {
      _audioSource =
          AudioSource.uri(Uri.file(mediaItem.extras!['url'].toString()));
    }
    //else {
    // if (downloadsBox.containsKey(mediaItem.id) && useDown) {
    //   _audioSource = AudioSource.uri(
    //     Uri.file(
    //       (downloadsBox.get(mediaItem.id) as Map)['path'].toString(),
    //     ),
    //   );
    // }
    else {
      // if (cacheSong) {
      //   _audioSource = LockCachingAudioSource(
      //     Uri.parse(
      //       mediaItem.extras!['url'].toString().replaceAll(
      //             '_96.',
      //             "_${preferredQuality.replaceAll(' kbps', '')}.",
      //           ),
      //     ),
      //   );
      // } else {
      _audioSource = AudioSource.uri(
        Uri.parse(mediaItem.extras!['url']),
      );
      // }
      //     }
    }

    //_mediaItemExpando[_audioSource] = mediaItem;
    return _audioSource;
  }

  List<AudioSource> _itemsToSources(List<MediaItem> mediaItems) {
    // preferredQuality = Hive.box('settings')
    //     .get('streamingQuality', defaultValue: '96 kbps')
    //     .toString();
    // cacheSong =
    //     Hive.box('settings').get('cacheSong', defaultValue: false) as bool;
    //useDown = Hive.box('settings').get('useDown', defaultValue: true) as bool;
    return mediaItems.map(_itemToSource).toList();
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    _playlist.removeAt(index);

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  // @override
  // Future<void> removeQueueItem(MediaItem mediaItem) {
  //   // TODO: implement removeQueueItem
  //   return super.removeQueueItem(mediaItem);
  // }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future getPlaying() async {
    return _player.playing;
  }
}
