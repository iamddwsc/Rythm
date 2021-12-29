class Song {
  String? songImage;
  String? songTitle;
  String? songArtist;
  String? songOfAlbum;
  String? songDateRelease;
  String? mp3Url128;
  String? mp3Url320;
  dynamic? mp3Url500;

  Song(
      {this.songImage,
      this.songTitle,
      this.songArtist,
      this.songOfAlbum,
      this.songDateRelease,
      this.mp3Url128,
      this.mp3Url320,
      this.mp3Url500});

  Song.fromJson(Map<String, dynamic> json) {
    this.songImage = json["song_image"];
    this.songTitle = json["song_title"];
    this.songArtist = json["song_artist"];
    this.songOfAlbum = json["song_of_album"];
    this.songDateRelease = json["song_date_release"];
    this.mp3Url128 = json["mp3_url_128"];
    this.mp3Url320 = json["mp3_url_320"];
    this.mp3Url500 = json["mp3_url_500"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["song_image"] = this.songImage;
    data["song_title"] = this.songTitle;
    data["song_artist"] = this.songArtist;
    data["song_of_album"] = this.songOfAlbum;
    data["song_date_release"] = this.songDateRelease;
    data["mp3_url_128"] = this.mp3Url128;
    data["mp3_url_320"] = this.mp3Url320;
    data["mp3_url_500"] = this.mp3Url500;
    return data;
  }
}
