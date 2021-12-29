class SliderInfo {
  String? sliderId;
  String? sliderImage;
  String? sliderTitle;
  String? sliderArtist;
  String? sliderHref;

  SliderInfo(
      {this.sliderId,
      this.sliderImage,
      this.sliderTitle,
      this.sliderArtist,
      this.sliderHref});

  SliderInfo.fromJson(Map<String, dynamic> json) {
    this.sliderId = json["slider_id"];
    this.sliderImage = json["slider_image"];
    this.sliderTitle = json["slider_title"];
    this.sliderArtist = json["slider_artist"];
    this.sliderHref = json["slider_href"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["slider_id"] = this.sliderId;
    data["slider_image"] = this.sliderImage;
    data["slider_title"] = this.sliderTitle;
    data["slider_artist"] = this.sliderArtist;
    data["slider_href"] = this.sliderHref;
    return data;
  }
}
