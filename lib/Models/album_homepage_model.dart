import 'package:rythm/Models/search_result.dart';

class AlbumHomePage {
  String? itemTitle;
  String? itemArtist;
  String? itemImage;
  String? itemHref;

  AlbumHomePage(
      {this.itemTitle, this.itemArtist, this.itemImage, this.itemHref});

  AlbumHomePage.fromJson(Map<String, dynamic> json) {
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

  AlbumHomePage.cast(Album album) {
    this.itemTitle = album.itemTitle;
    this.itemArtist = album.itemArtist;
    this.itemImage = album.itemImage;
    this.itemHref = album.itemHref;
  }

  AlbumHomePage.castToSong(Song song) {
    this.itemTitle = song.itemTitle;
    this.itemArtist = song.itemArtist;
    this.itemImage = song.itemImage;
    this.itemHref = song.itemHref;
  }

  // List<AlbumHomePage> castToAlbumHomePage(SearchResult sr) {
  //   List<AlbumHomePage> list = sr.album!.map((e) => null);
  // }
}
