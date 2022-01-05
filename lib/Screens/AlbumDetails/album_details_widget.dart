import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:rythm/APIs/api.dart';
import 'package:rythm/APIs/api_services.dart';
import 'package:rythm/Models/boxes.dart';
import 'package:rythm/Screens/AlbumDetails/album_page_header.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Models/album_homepage_model.dart';
import 'package:rythm/Screens/AlbumDetails/my_space_bar.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:rythm/Screens/Player/mini_player.dart';
import 'package:rythm/Screens/Player/player_screen.dart';
import 'package:rythm/Services/audio_manager.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'package:rythm/app_color.dart' as AppColors;

class AlbumDetails extends StatefulWidget {
  const AlbumDetails({Key? key, required this.albumHomePage}) : super(key: key);

  final AlbumHomePage? albumHomePage;

  @override
  _AlbumDetailsState createState() => _AlbumDetailsState();
}

class _AlbumDetailsState extends State<AlbumDetails> {
  // final AlbumHomePage _albumHomePage = widget.albumHomePage;
  ScrollController _controller = new ScrollController();
  final ScrollController _controllerLV = new ScrollController();
  Future<List<Album>>? data;
  List<Album>? albumList;
  late bool getPlayerFlag;
  //final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  final box = Boxes.getPlaying();
  final myPlayingAlbumBox = Boxes.getPlayingAlbum();

  @override
  var top = 340.0;
  void initState() {
    //getColor();
    // TODO: implement initState
    data = initData();
    _controller.addListener(() => setState(() {}));
    //myColor = getColor();

    // getPlayerFlag = Hive.get
    super.initState();
  }

  Future<List<Album>> initData() async {
    //myPlayingAlbumBox.put('myWatchingAlbum', widget.albumHomePage!.itemTitle!);
    final response = await http.post(
        Uri.parse(RythmAPI().API + RythmAPI().ALBUM),
        body: jsonEncode(_getData()),
        headers: _setHeaders());

    final String jsonBody = response.body;
    final int statusCode = response.statusCode;
    if (statusCode != 200 || jsonBody == null) {
      print(response.reasonPhrase);
      throw new Exception("Lỗi load api");
    } else {
      final JsonDecoder _decoder = new JsonDecoder();
      final useListContainer = _decoder.convert(jsonBody);
      final List albumList = useListContainer['album_info'];
      //print(sliderList);
      return albumList.map((e) => Album.fromJson(e)).toList();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  //List<Song> myList = [];

  Future initPlaying() async {
    //print(albumList!.length);
    if (box.isNotEmpty) {
      await box.deleteAll(box.keys);
    }

    for (var item in albumList!) {
      //myList.add(item.song![0]);
      await box.add(item.song![0]);
    }
    //print(box.values.toList().length);
  }

  Widget _buildFab() {
    final double defaultTopMargin = 325;
    //pixels from top where scaling should start
    double top = defaultTopMargin;
    if (_controller.hasClients) {
      setState(() {
        double offset = _controller.offset;
        top -= offset;
      });
    }

    return Positioned(
      top: top > 27.0 ? top : 27.0,
      right: 10.0,
      child: FloatingActionButton(
          backgroundColor: Colors.blue[500],
          elevation: 10.0,
          onPressed: () => {
                // if (albumList!.isNotEmpty) {box.add(albumList![0])}
                //print(albumList!.length),
                if (box.isNotEmpty) {box.deleteAll(box.keys)},

                for (var item in albumList!) {box.add(item.song![0])},
                //print(box.values.toList().length)
              },
          child: Image.asset('assets/play2.png',
              height: 18.0, width: 18.0, color: Colors.white)),
    );
  }

  _getData() {
    var data = {'url_info': widget.albumHomePage!.itemHref};
    return data;
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //     colors: [
              //   Colors.black.withOpacity(0.8),
              //   Colors.black.withOpacity(0.9),
              //   Color(0xFF121212)
              // ],
              //     stops: [
              //   0.5,
              //   0.65,
              //   0.8
              // ])),
              color: Colors.white,
            ),
            child: FutureBuilder<List<Color>>(
                future: getMedianColor(widget.albumHomePage!.itemImage),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.hasError) {
                    return Container(
                      child: Center(
                        child: Container(
                            height: MediaQuery.of(context).size.width * 0.85,
                            child: Center(child: CircularProgressIndicator())),
                      ),
                    );
                  }
                  return CustomScrollView(
                    shrinkWrap: true,
                    controller: _controller,
                    slivers: <Widget>[
                      SliverAppBar(
                        pinned: true,
                        floating: false,
                        backgroundColor: Colors.white,
                        expandedHeight: 276.0,
                        flexibleSpace: Material(
                          child: MyAppSpace(
                            title: widget.albumHomePage!.itemTitle!,
                            urlimage: widget.albumHomePage!.itemImage!,
                            albumArtist: widget.albumHomePage!.itemArtist!,
                            color: snapshot.data![0],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                          child: Column(
                        children: [
                          AlbumPageHeader(
                              albumTitle: widget.albumHomePage!.itemTitle!,
                              albumArtist: widget.albumHomePage!.itemArtist!,
                              color: snapshot.data![0]),
                          FutureBuilder<List<Album>>(
                              future: data,
                              builder: (context, _snapshot) {
                                if ((_snapshot.hasError) ||
                                    (!_snapshot.hasData)) {
                                  return Center(
                                    child: Container(
                                        height: 265.0,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator())),
                                  );
                                }
                                //print(myColor);
                                albumList = _snapshot.data;

                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    controller: _controllerLV,
                                    itemCount: albumList!.length,
                                    itemBuilder: (context, index) {
                                      return SongItem(
                                          album: albumList?[index],
                                          index: index,
                                          boxPlaying: box,
                                          albumList: albumList,
                                          current:
                                              widget.albumHomePage!.itemTitle!,
                                          color: snapshot.data![0]);
                                    });
                              }),
                          SizedBox(
                            height: 70.0,
                          )
                        ],
                      )),
                    ],
                  );
                }),
          ),
          _buildFab()
        ],
      ),
    );
  }
}

class SongItem extends StatefulWidget {
  const SongItem(
      {Key? key,
      required this.album,
      required this.index,
      required this.boxPlaying,
      required this.albumList,
      required this.current,
      required this.color})
      : super(key: key);

  final Album? album;
  final int index;
  final String current;
  final Color color;

  final boxPlaying;
  final List<Album>? albumList;

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  @override
  void initState() {
    super.initState();
  }

  final AudioManager _audioManager = GetIt.I<AudioManager>();
  void initPlaying() async {
    final boxPlaying = Boxes.getPlaying();
    //final myPlayingAlbumBox = Boxes.getPlayingAlbum();
    if (boxPlaying.isNotEmpty) {
      boxPlaying.deleteAll(widget.boxPlaying.keys);
    }
    for (var item in widget.albumList!) {
      item.song![0].main_url = item.itemHref;
      boxPlaying.add(item.song![0]);
      // print('aaaaa ${item.song![0].lossless}');
    }
    //if (myPlayingAlbumBox.get('myPlayingAlbum') == "abc") {}
    await _audioManager.newPlaylist2(widget.index, widget.current);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.white,
      child: Container(
        height: 70.0,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            initPlaying();
            final boxIndex = Boxes.getPlayingIndex();
            boxIndex.put('myPlayingIndex', widget.index);
            setState(() {});
          },
          child: Container(
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: widget
                              .albumList![widget.index].song![0].songImage! ==
                          ""
                      ? 'https://developers.google.com/maps/documentation/maps-static/images/error-image-generic.png?hl=vi'
                      : widget.album!.song![0].songImage!,
                  fit: BoxFit.contain,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  padding: EdgeInsets.only(left: 15.0, top: 7.0, bottom: 7.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.album!.itemTitle!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            // color: isLightColor(widget.color)
                            //     ? darken(widget.color, .4)
                            //     : lighten(widget.color, 0.1))),
                          )),
                      Text(widget.album!.itemArtist!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.0,
                            //fontWeight: FontWeight.w400,
                            // color: isLightColor(widget.color)
                            //     ? darken(widget.color, .4)
                            //     : lighten(widget.color, 0.1)))
                          ))
                    ],
                  ),
                ),
                Expanded(child: Container()),
                IconButton(
                    onPressed: () {
                      final snackBar = SnackBar(content: Text('Null'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    icon: Icon(
                      Icons.more_vert_outlined,
                      // color: isLightColor(widget.color)
                      //     ? darken(widget.color, .4)
                      //     : lighten(widget.color, 0.1),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
