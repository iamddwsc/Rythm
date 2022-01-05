class Lyrics {
  List<String>? data;

  Lyrics({this.data});

  Lyrics.fromJson(Map<String, dynamic> json) {
    this.data = json["data"] == null ? null : List<String>.from(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) data["data"] = this.data;
    return data;
  }
}
