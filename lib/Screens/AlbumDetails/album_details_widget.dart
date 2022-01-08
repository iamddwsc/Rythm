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
import 'package:rythm/Screens/AlbumDetails/album_view_panel.dart';
import 'package:rythm/Screens/AlbumDetails/my_space_bar.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:rythm/Screens/Player/mini_player.dart';
import 'package:rythm/Screens/Player/panel_widget.dart';
import 'package:rythm/Screens/Player/player_screen.dart';
import 'package:rythm/Services/audio_manager.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'package:rythm/app_color.dart' as AppColors;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AlbumDetails extends StatefulWidget {
  const AlbumDetails({Key? key, required this.albumHomePage}) : super(key: key);

  final AlbumHomePage? albumHomePage;

  @override
  _AlbumDetailsState createState() => _AlbumDetailsState();
}

class _AlbumDetailsState extends State<AlbumDetails> {
  final PanelController _pc = new PanelController();
  ScrollController _controller = new ScrollController();
  final ScrollController _controllerLV = new ScrollController();
  Future<List<Album>>? data;
  List<Album>? albumList;
  Song? songInfo;
  //String? songInfoMainURL;
  late bool getPlayerFlag;
  final box = Boxes.getPlaying();
  final myPlayingAlbumBox = Boxes.getPlayingAlbum();
  var top = 340.0;

  @override
  void initState() {
    // TODO: implement initState
    data = initData();
    _controller.addListener(() => setState(() {}));
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

  _getData() {
    var data = {'url_info': widget.albumHomePage!.itemHref};
    return data;
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    _controllerLV.dispose();
    super.dispose();
  }

  Future initPlaying() async {
    if (box.isNotEmpty) {
      await box.deleteAll(box.keys);
    }
    for (var item in albumList!) {
      await box.add(item.song![0]);
    }
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
      child: SizedBox(
        width: 50.0,
        child: FloatingActionButton(
            enableFeedback: false,
            backgroundColor: Colors.blue[500],
            elevation: 7.0,
            onPressed: () => {
                  if (box.isNotEmpty) {box.deleteAll(box.keys)},
                  for (var item in albumList!) {box.add(item.song![0])},
                },
            child: Image.asset('assets/play2.png',
                height: 18.0, width: 18.0, color: Colors.white)),
      ),
    );
  }

  void getSongInfo(int index) {
    songInfo = albumList![index].song![0];
    setState(() {});
    print(songInfo!.songTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SlidingUpPanel(
        maxHeight: MediaQuery.of(context).size.height * 0.56,
        minHeight: 0.0,
        backdropEnabled: true,
        backdropOpacity: 0.5,
        backdropColor: Colors.black,
        isDraggable: false,
        color: Colors.transparent,
        controller: _pc,
        panelBuilder: (controller) => AlbumViewPanel(
            panelController: _pc,
            info: songInfo,
            //mainUrl: songInfoMainURL,
            color: Colors.black.withOpacity(0.8)),
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
                              child:
                                  Center(child: CircularProgressIndicator())),
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
                                  songInfo = albumList![0].song![0];
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
                                          color: snapshot.data![0],
                                          panelController: _pc,
                                          onSongSelect: (int indexz) {
                                            songInfo =
                                                albumList![indexz].song![0];
                                            // songInfoMainURL =
                                            //     albumList![indexz].itemHref;
                                            songInfo!.main_url =
                                                albumList![indexz].itemHref;
                                            setState(() {});
                                            //print(songInfo!.songSinger);
                                          },
                                        );
                                      });
                                }),
                            SizedBox(
                              height: 88.0,
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
      required this.color,
      required this.panelController,
      required this.onSongSelect})
      : super(key: key);

  final Album? album;
  final int index;
  final String current;
  final Color color;
  final PanelController panelController;

  final boxPlaying;
  final List<Album>? albumList;

  final SongCallback onSongSelect;

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
                              color: AppColors.textColor
                              // color: isLightColor(widget.color)
                              //     ? darken(widget.color, .4)
                              //     : lighten(widget.color, 0.1))),
                              )),
                      Text(widget.album!.itemArtist!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14.0, color: AppColors.textColor
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
                      // final snackBar = SnackBar(content: Text('Null'));
                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      //_audioManager.add()

                      widget.onSongSelect(widget.index);
                      widget.panelController.open();
                    },
                    enableFeedback: false,
                    icon: Icon(
                      Icons.more_vert_outlined,
                      color: AppColors.textColor,
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

typedef SongCallback = void Function(int index);
