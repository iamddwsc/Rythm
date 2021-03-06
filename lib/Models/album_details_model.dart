import 'package:hive/hive.dart';

part 'album_details_model.g.dart';

@HiveType(typeId: 0)
class Album {
  @HiveField(0)
  String? itemTitle;
  @HiveField(1)
  String? itemArtist;
  @HiveField(2)
  String? itemHref;
  @HiveField(3)
  List<Song>? song;

  Album({this.itemTitle, this.itemArtist, this.itemHref, this.song});

  Album.fromJson(Map<String, dynamic> json) {
    this.itemTitle = json["item_title"];
    this.itemArtist = json["item_artist"];
    this.itemHref = json["item_href"];
    this.song = json["song"] == null
        ? null
        : (json["song"] as List).map((e) => Song.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["item_title"] = this.itemTitle;
    data["item_artist"] = this.itemArtist;
    data["item_href"] = this.itemHref;
    if (this.song != null)
      data["song"] = this.song?.map((e) => e.toJson()).toList();
    return data;
  }
}

@HiveType(typeId: 1)
class Song {
  @HiveField(0)
  String? songImage;
  @HiveField(1)
  String? songTitle;
  @HiveField(2)
  String? songSinger;
  @HiveField(3)
  String? songWriter;
  @HiveField(4)
  String? songOfAlbum;
  @HiveField(5)
  String? songDateRelease;
  @HiveField(6)
  String? mp3Url128;
  @HiveField(7)
  String? mp3Url320;
  @HiveField(8)
  String? mp3Url500;
  @HiveField(9)
  String? lossless;
  @HiveField(10)
  String? main_url;

  set mainUrl(String url) => main_url = url;

  Song(
      {this.songImage,
      this.songTitle,
      this.songSinger,
      this.songWriter,
      this.songOfAlbum,
      this.songDateRelease,
      this.mp3Url128,
      this.mp3Url320,
      this.mp3Url500,
      this.lossless});

  Song.fromJson(Map<String, dynamic> json) {
    this.songImage = json["song_image"];
    this.songTitle = json["song_title"];
    this.songSinger = json["song_singer"];
    this.songWriter = json["songWriter"];
    this.songOfAlbum = json["song_of_album"];
    this.songDateRelease = json["song_date_release"];
    this.mp3Url128 = json["mp3_url_128"];
    this.mp3Url320 = json["mp3_url_320"];
    this.mp3Url500 = json["mp3_url_500"];
    this.lossless = json["lossless"];
    //this.main_url = json["main_url"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["song_image"] = this.songImage;
    data["song_title"] = this.songTitle;
    data["song_singer"] = this.songSinger;
    data["songWriter"] = this.songWriter;
    data["song_of_album"] = this.songOfAlbum;
    data["song_date_release"] = this.songDateRelease;
    data["mp3_url_128"] = this.mp3Url128;
    data["mp3_url_320"] = this.mp3Url320;
    data["mp3_url_500"] = this.mp3Url500;
    data["lossless"] = this.lossless;
    return data;
  }
}
