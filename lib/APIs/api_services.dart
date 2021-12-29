import 'dart:convert';

import 'package:rythm/APIs/api.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Models/album_homepage_model.dart';
import 'package:rythm/Models/slider_info_model.dart';
import 'package:http/http.dart' as http;
import 'package:rythm/Screens/AlbumDetails/album_details_widget.dart';

class ApiServices {
  Future<List<SliderInfo>> fetchSlider() async {
    // String uri = RythmAPI().API + RythmAPI().SLIDER
    return http
        .get(Uri.parse(RythmAPI().API + RythmAPI().SLIDER))
        .then((http.Response response) {
      final String jsonBody = response.body;
      final int statusCode = response.statusCode;
      var body = json.decode(response.body);

      if (statusCode != 200 || jsonBody == null) {
        print(response.reasonPhrase);
        throw new Exception("Lỗi load api");
      }

      final JsonDecoder _decoder = new JsonDecoder();
      final useListContainer = _decoder.convert(jsonBody);
      final List sliderList = useListContainer['slider_info'];
      final bool success = useListContainer['success'];
      //print(sliderList);
      return sliderList.map((e) => SliderInfo.fromJson(e)).toList();
    });
  }

  Future<List<AlbumHomePage>> fetchAlbumHomePage(String country) async {
    // String uri = RythmAPI().API + RythmAPI().SLIDER
    return http
        .get(Uri.parse(RythmAPI().API + country))
        .then((http.Response response) {
      final String jsonBody = response.body;
      final int statusCode = response.statusCode;

      if (statusCode != 200 || jsonBody == null) {
        print(response.reasonPhrase);
        throw new Exception("Lỗi load api");
      }

      final JsonDecoder _decoder = new JsonDecoder();
      final useListContainer = _decoder.convert(jsonBody);
      final List sliderList = useListContainer['new_album'];
      //print(sliderList);
      return sliderList.map((e) => AlbumHomePage.fromJson(e)).toList();
    });
  }

  Future<List<Album>> fetchAlbumDetails(apiUrl, var data) async {
    final response = await http.post(
        Uri.parse(RythmAPI().API + RythmAPI().ALBUM),
        body: jsonEncode(data),
        headers: _setHeaders());

    final String jsonBody = response.body;
    final int statusCode = response.statusCode;
    if (statusCode != 200 || jsonBody == null) {
      print(response.reasonPhrase);
      throw new Exception("Lỗi load api");
    }
    final JsonDecoder _decoder = new JsonDecoder();
    final useListContainer = _decoder.convert(jsonBody);
    final List albumList = useListContainer['album_info'];
    //print(sliderList);
    return albumList.map((e) => Album.fromJson(e)).toList();
  }

  postData(data, apiUrl) async {
    var fullUrl = RythmAPI().API + apiUrl;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
}
