import 'package:hive/hive.dart';
import 'package:rythm/Models/album_details_model.dart';

class Boxes {
  static Box<Song> getPlaying() => Hive.box<Song>('playing');
  static Box<int> getPlayingIndex() => Hive.box<int>('currentPlayingIndex');
  static Box<String> getPlayingAlbum() =>
      Hive.box<String>('currentPlayingAlbum');
}
