import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:rythm/APIs/api.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Models/album_homepage_model.dart';
import 'package:rythm/Models/search_result.dart';
import 'package:rythm/Screens/AlbumDetails/album_details_widget.dart';
import 'package:rythm/app_color.dart' as AppColors;

class SearchLayout extends StatefulWidget {
  const SearchLayout({Key? key}) : super(key: key);

  @override
  _SearchLayoutState createState() => _SearchLayoutState();
}

class _SearchLayoutState extends State<SearchLayout> {
  //TextEditingController _textEditingController = new TextEditingController();
  final _searchQuery = new TextEditingController();
  Timer? _debounce;
  final _searchResult = ValueNotifier<List<SearchResult>>([]);
  //String _tag = "Album";
  final _tag = ValueNotifier<String>('');
  bool _focus = true;
  final String errorImage =
      'https://developers.google.com/maps/documentation/maps-static/images/error-image-generic.png?hl=vi';

  @override
  void initState() {
    super.initState();
    _searchQuery.addListener(_onSearchChanged);
    _tag.value = "Album";
  }

  @override
  void dispose() {
    _searchQuery.removeListener(_onSearchChanged);
    _searchQuery.dispose();
    _debounce?.cancel();
    //n.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      //getPlacesFromHereMaps(query);
      //searching(_searchQuery.text);
      if (_searchQuery.text.replaceAll(' ', '').length > 0) {
        searching(_searchQuery.text);
      }
      if (_searchQuery.text.replaceAll(' ', '').length == 0) {
        _searchResult.value = [];
      }
      setState(() {});
      // if (_searchQuery.text.length > 0 && _searchQuery.text.)
    });
  }

  void searching(String query) async {
    print('send request');
    List<dynamic> data = await Search(query).catchError((e) {
      print("have an error");

      return List.generate(1, (index) => SearchResult.fromJson(errorJson));
    });
    // _searchResult.value = await Search(query).catchError((e) {
    //   print("have an error");
    //   return [];
    // });
    if (data != null) {
      _searchResult.value = data.cast<SearchResult>();
    } else {
      _searchResult.value = [];
    }
    if (mounted) {
      setState(() {});
    }
  }

  //final myJsonAsString = '{"album": [], "song": []}';
  final errorJson = json.decode('{"album": [], "song": []}');

  Future Search(String myQuery) async {
    final response = await http.post(
        Uri.parse(RythmAPI().API + RythmAPI().SEARCH),
        body: jsonEncode(_getData(myQuery)),
        headers: _setHeaders());

    final String jsonBody = response.body;
    final int statusCode = response.statusCode;
    if (statusCode != 200 || jsonBody == null) {
      print(response.reasonPhrase);
      throw Exception("Lỗi load api");
    } else {
      final JsonDecoder _decoder = new JsonDecoder();
      final useListContainer = _decoder.convert(jsonBody);
      // final Map<String, dynamic> albumListFrist =
      //     useListContainer['seeker_result'];
      // final List albumList = albumListFrist as List<SearchResult>;
      // return albumList.map((e) => SearchResult.fromJson(e)).toList();
      List<SearchResult> list = new List.generate(1,
          (index) => SearchResult.fromJson(useListContainer['seeker_result']));
      //SearchResult.fromJson(albumListFrist) as List<SearchResult>;
      return list;
    }
  }

  _getData(String myQuery) {
    var data = {'myQuery': myQuery};
    return data;
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  // void callFocus() async {
  //   if (_focus) {
  //     FocusScope.of(context).requestFocus(n);
  //   }
  // }

  final ScrollController _controller = new ScrollController();
  bool pressAttention = false;
  //FocusNode n = new FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: TextField(
                  controller: _searchQuery,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          borderSide: BorderSide.none),
                      hintText: 'Search terms',
                      prefixIcon: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back_rounded),
                      )),
                  autofocus: true,
                  //focusNode: n,
                  // onSubmitted: ,
                ),
              )
            ],
          ),
          ValueListenableBuilder(
              valueListenable: _searchResult,
              builder: (context, List<SearchResult> data, _) {
                if (data.isNotEmpty) {
                  return Flexible(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buttonWidget("Album"),
                            _buttonWidget("Song")
                          ],
                        ),
                        ValueListenableBuilder(
                            valueListenable: _tag,
                            builder: (context, String tag, _) {
                              if (tag == "Album") {
                                return Flexible(
                                  child: Container(
                                      margin: EdgeInsets.only(
                                          left: 16.0, right: 16.0),
                                      child: _buildAlbumList(data[0])),
                                );
                              } else {
                                return Flexible(
                                  child: Container(
                                      margin: EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: _buildSongList(data[0])),
                                );
                              }
                            })
                      ],
                    ),
                  );
                } else {
                  return Visibility(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Play content you like',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColor),
                          ),
                          Text(
                            'Search for artists, songs, podcasts and more.',
                            style: TextStyle(
                                color: AppColors.textColor.withOpacity(0.8)),
                          )
                        ],
                      ),
                    ),
                    visible: true,
                  );
                }
              }),
        ],
      ),
    );
  }

  Widget _buttonWidget(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _tag.value = text;
        });
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        //width: 70.0,
        decoration: BoxDecoration(
          border: Border.all(
              color: _tag.value == text ? Colors.blue[500]! : Colors.black,
              width: 0.75),
          borderRadius: BorderRadius.circular(30.0),
          color: _tag.value == text ? Colors.blue[300] : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSongList(SearchResult data) {
    Widget itemCards;
    //List<AlbumHomePage>? list = AlbumHomePage.cast(data).;
    List<AlbumHomePage>? list =
        data.song!.map((e) => AlbumHomePage.castToSong(e)).toList();
    if (data == null) {
      list = [];
    }
    // if (searchResult.length )
    if (list.length > 0 && list != null) {
      itemCards = Flexible(
        child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AlbumDetails(
                            albumHomePage: list![index],
                          )));
                  _focus = false;
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 50.0,
                            child: CachedNetworkImage(
                                imageUrl: list![index].itemImage ?? errorImage),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.81,
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    list[index].itemTitle!,
                                    style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    list[index].itemArtist!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.subTextColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Builder(builder: (context) {
                        if (index == list!.length - 1) {
                          return SizedBox(
                            height: 60.0,
                          );
                        } else
                          return Visibility(
                            child: Divider(),
                            visible: false,
                          );
                      })
                    ],
                  ),
                ),
              );
            }),
      );
    } else {
      itemCards = Center(
        child: Container(
          margin: EdgeInsets.only(bottom: 125.0),
          child: Text('No items'),
        ),
      );
    }
    return itemCards;
  }

  Widget _buildAlbumList(SearchResult data) {
    Widget itemCards;
    //List<AlbumHomePage>? list = AlbumHomePage.cast(data).;
    List<AlbumHomePage>? list =
        data.album!.map((e) => AlbumHomePage.cast(e)).toList();
    if (data == null) {
      list = [];
    }
    // if (searchResult.length )
    if (list.length > 0 && list != null) {
      itemCards = AlignedGridView.count(
          controller: _controller,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          crossAxisCount: 2,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 12.0,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AlbumDetails(
                          albumHomePage: list![index],
                        )));
                _focus = false;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                      imageUrl: list![index].itemImage == ""
                          ? errorImage
                          : list[index].itemImage!,
                      fit: BoxFit.contain),
                  // SizedBox(
                  //   height: 5.0,
                  // ),
                  Container(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      list[index].itemTitle ?? "Null",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        //height: 1.1,
                        color: AppColors.textColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(2.0),
                    child: Text(
                      list[index].itemArtist ?? "Null",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        //height: 1.1,
                        color: AppColors.subTextColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Builder(builder: (context) {
                    if (index == list!.length - 1) {
                      return SizedBox(
                        height: 70.0,
                      );
                    } else {
                      return Visibility(
                        child: Divider(),
                        visible: false,
                      );
                    }
                  })
                ],
              ),
            );
          });
    } else {
      itemCards = Center(
        child: Container(
          margin: EdgeInsets.only(bottom: 125.0),
          child: Text('No items'),
        ),
      );
    }
    return itemCards;
  }
}
