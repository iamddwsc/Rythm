import 'package:rythm/Models/album_homepage_model.dart';

class SearchResult {
  List<Album>? album;
  List<Song>? song;

  SearchResult({this.album, this.song});

  SearchResult.fromJson(Map<String, dynamic> json) {
    this.album = json["album"] == null
        ? null
        : (json["album"] as List).map((e) => Album.fromJson(e)).toList();
    this.song = json["song"] == null
        ? null
        : (json["song"] as List).map((e) => Song.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.album != null)
      data["album"] = this.album?.map((e) => e.toJson()).toList();
    if (this.song != null)
      data["song"] = this.song?.map((e) => e.toJson()).toList();
    return data;
  }

  // SearchResult.castToAlbumHomePage(SearchResult sr) {
  //   List<AlbumHomePage> list = this.album.map((e) => return )
  // }
}

class Song {
  String? itemTitle;
  String? itemArtist;
  String? itemImage;
  String? itemHref;

  Song({this.itemTitle, this.itemArtist, this.itemImage, this.itemHref});

  Song.fromJson(Map<String, dynamic> json) {
    this.itemTitle = json["item_title"];
    this.itemArtist = json["item_artist"];
    this.itemImage = json["item_image"];
    this.itemHref = json["item_href"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["item_title"] = this.itemTitle;
    data["item_artist"] = this.itemArtist;
    data["item_image"] = this.itemImage;
    data["item_href"] = this.itemHref;
    return data;
  }
}

class Album {
  String? itemTitle;
  String? itemArtist;
  String? itemImage;
  String? itemHref;

  Album({this.itemTitle, this.itemArtist, this.itemImage, this.itemHref});

  Album.fromJson(Map<String, dynamic> json) {
    this.itemTitle = json["item_title"];
    this.itemArtist = json["item_artist"];
    this.itemImage = json["item_image"];
    this.itemHref = json["item_href"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["item_title"] = this.itemTitle;
    data["item_artist"] = this.itemArtist;
    data["item_image"] = this.itemImage;
    data["item_href"] = this.itemHref;
    return data;
  }
}
