import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Models/boxes.dart';
import 'package:rythm/Screens/Player/player_screen.dart';
import 'package:rythm/Services/notifiers/play_button_notifier.dart';
import 'package:rythm/Services/notifiers/progress_notifier.dart';
import 'package:rythm/Services/notifiers/repeat_button_notifier.dart';
import 'package:rythm/Services/playlist_repository.dart';
import 'package:rythm/Utils/calc_median_color.dart';

class AudioManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentSongNotifier = ValueNotifier<Map<dynamic, dynamic>>({});
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = GetIt.I<AudioHandler>();

  // Events: Calls coming from the UI
  void init() async {
    await loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> loadPlaylist() async {
    //print(_audioHandler.updateQueue(queue));
    final box = Boxes.getPlaying();
    List<Song> playlist = box.values.toList();
    // for (Song song in songs) {
    //   audioHandler.removeQueueItem(MediaItem(
    //       id: song.songTitle!,
    //       title: song.songTitle!,
    //       artist: song.songArtist,
    //       artUri: Uri.parse(song.songImage!),
    //       album: song.songOfAlbum,
    //       extras: {'url': song.mp3Url128}));
    // }
    // final songRepository = GetIt.I<PlaylistRepository>();
    //final playlist = await songRepository.fetchInitialPlaylist();
    //final playlist;
    final mediaItems = playlist
        .map((song) => MediaItem(
                id: song.songTitle!,
                title: song.songTitle!,
                artist: song.songSinger!.toString(),
                artUri: Uri.parse(song.songImage!),
                album: song.songOfAlbum,
                extras: {
                  'url': song.mp3Url128,
                  'mp3_url_128': song.mp3Url128,
                  'mp3_url_320': song.mp3Url320,
                  'mp3_url_500': song.mp3Url500,
                  'lossless': song.lossless
                }))
        .toList();

    //print(mediaItems.length);
    if (mediaItems.length > 0) {
      await _audioHandler.addQueueItems(mediaItems);
      final index = Boxes.getPlayingIndex();
      //index.put('myPlayingIndex', index.get('myPlayingIndex')! + 1);
      var i = index.get('myPlayingIndex');
      if (i != null) {
        _audioHandler.skipToQueueItem(i);
      }
    }
  }

  Future<void> newPlaylist2(index, String current) async {
    final box = Boxes.getPlaying();
    final playingIndex = Boxes.getPlayingIndex();
    List<Song> new_playlist = box.values.toList();
    final oldPlayingAlbum = Boxes.getPlayingAlbum();
    final mediaItems = new_playlist
        .map((song) => MediaItem(
                id: song.songTitle!,
                title: song.songTitle!,
                artist: song.songSinger!.toString(),
                artUri: Uri.parse(song.songImage!),
                album: song.songOfAlbum,
                extras: {
                  'url': song.mp3Url128,
                  'mp3_url_128': song.mp3Url128,
                  'mp3_url_320': song.mp3Url320,
                  'mp3_url_500': song.mp3Url500,
                  'lossless': song.lossless
                }))
        .toList();
    final old = oldPlayingAlbum.get('old');
    if (old == current) {
      _audioHandler.skipToQueueItem(index);
      //print('aaaaaa EQUAL: ${old} AND ${current}');
    } else {
      await _audioHandler.updateQueue(mediaItems);
      await _audioHandler.skipToQueueItem(index);
      //print('aaaaaa NOT EQUAL: ${old} AND ${current}');
      oldPlayingAlbum.put('old', current);
    }

    if (!_audioHandler.playbackState.value.playing) {
      _audioHandler.play();
    }
    playingIndex.put('myPlayingIndex', index);
    // print(
    //     'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab ${playingIndex.get('myPlayingIndex')}');
    // print('aaaaaaaccccccccbbbb ${mediaItems.length}');
    // print('aaaazzzzzzzzz ${_audioHandler.playbackState.value.playing}');
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
        currentSongNotifier.value = {};
      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
        //print('aaaaaaList ${newList}');
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        // final boxIndex = Boxes.getPlayingIndex();
        // boxIndex.put('myPlayingIndex', boxIndex.get('myPlayingIndex')! + 1);
        // print('aaaaaaaaaaboxindex ${boxIndex.get('myPlayingIndex')}');
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      //final newSong = ['title' : mediaItem?.title, 'artist': mediaItem?.artist];
      //var medianColor = getMedianColor(mediaItem!.artUri);
      currentSongNotifier.value = {};
      final newSong = {
        'title': mediaItem!.title,
        'artist': mediaItem.artist,
        'artUri': mediaItem.artUri,
        'album': mediaItem.album,
        'mp3_url_128': mediaItem.extras!['mp3_url_128'],
        'mp3_url_320': mediaItem.extras!['mp3_url_128'],
        'mp3_url_500': mediaItem.extras!['mp3_url_128'],
        'lossless': mediaItem.extras!['lossless']
      };
      // final index = Boxes.getPlayingIndex();
      // index.put('myPlayingIndex', index.get('myPlayingIndex')! + 1);
      currentSongNotifier.value = newSong;

      _updateSkipButtons();
    });
  }

  // Color _passColor(color) {
  //   return color;
  // }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();
  // GestureDragEndCallback dragToNext() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> add() async {
    final songRepository = GetIt.I<PlaylistRepository>();
    final song = await songRepository.fetchAnotherSong();
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    _audioHandler.addQueueItem(mediaItem);
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }

  void playAtIndex(index) {
    _audioHandler.skipToQueueItem(index);
    //_audioHandler.play();
  }
}
