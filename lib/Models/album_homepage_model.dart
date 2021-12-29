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
}
