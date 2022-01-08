import 'dart:convert';
import 'dart:ui';
import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rythm/APIs/api.dart';
import 'package:rythm/Models/lyrics.dart';
import 'package:rythm/Screens/Player/download_panel.dart';
import 'package:rythm/Screens/Player/panel_widget.dart';
import 'package:rythm/Services/audio_manager.dart';
import 'package:rythm/Services/notifiers/play_button_notifier.dart';
import 'package:rythm/Services/notifiers/progress_notifier.dart';
import 'package:rythm/Services/notifiers/repeat_button_notifier.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'package:rythm/app_color.dart' as AppColors;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;

class PlayerScreen extends StatefulWidget {
  const PlayerScreen(
      {Key? key,
      required this.myColor,
      required this.mostColor,
      required this.mostColor2,
      required this.info})
      : super(key: key);
  final Color myColor;
  final Color mostColor;
  final Color mostColor2;
  final Map<dynamic, dynamic> info;
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PanelController _pc = new PanelController();
  final PanelController _pc2 = new PanelController();
  final ScrollController controller = new ScrollController();
  ReceivePort _port = ReceivePort();
  var lyrics = ValueNotifier<List<dynamic>>([]);

  Future<bool> _onWillPop() async {
    if (_pc.isPanelOpen) {
      _pc.close();
      return false;
    } else if (_pc2.isPanelOpen) {
      _pc2.close();
      return false;
    } else {
      return true;
    }
  }

  void getLyrics(String url) async {
    final temp = await fetchLyrics(url);
    lyrics.value = temp;
    //print('aaaaaa test ${lyrics.runtimeType}');
  }

  Future fetchLyrics(String url_info) async {
    final response = await http.post(
        Uri.parse(RythmAPI().API + RythmAPI().LYRIC),
        body: jsonEncode(_getData(url_info)),
        headers: _setHeaders());

    final String jsonBody = response.body;
    final int statusCode = response.statusCode;
    if (statusCode != 200 || jsonBody == null) {
      print(response.reasonPhrase);
      throw new Exception("Lỗi load api");
    } else {
      final JsonDecoder _decoder = new JsonDecoder();
      final useListContainer = _decoder.convert(jsonBody);
      final List lyrics = useListContainer['data'];
      return lyrics;
    }
  }
  // Future<List<String>> fetchLyrics(String url_info) async {
  //   final List<String> abc = ['test'];
  //   return abc;
  // }

  _getData(String url_info) {
    var data = {'url_info': url_info};
    return data;
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    getLyrics(widget.info['main_url']);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Widget lyricWidget(String txt) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      width: MediaQuery.of(context).size.width * 0.9,
      child: Text(txt,
          style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.w900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AudioManager audioManager = GetIt.I<AudioManager>();

    return SafeArea(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            //appBar: AppBar(),
            body: ValueListenableBuilder(
                valueListenable: audioManager.currentSongNotifier,
                builder: (context, Map<dynamic, dynamic> info, _) {
                  getLyrics(info['main_url']);
                  return SlidingUpPanel(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                    minHeight: 0.0,
                    backdropEnabled: true,
                    backdropOpacity: 0.5,
                    backdropColor: Colors.black,
                    // parallaxEnabled: true,
                    // parallaxOffset: 0.2,
                    isDraggable: false,
                    color: Colors.transparent,
                    controller: _pc,
                    panelBuilder: (controller) => PanelWidget(
                        controller: controller,
                        panelController: _pc,
                        downloadPanelControler: _pc2,
                        info: info,
                        color: widget.myColor),
                    body: SlidingUpPanel(
                      maxHeight: MediaQuery.of(context).size.height * 0.454,
                      minHeight: 0.0,
                      backdropEnabled: true,
                      backdropOpacity: 0.5,
                      backdropColor: Colors.black,
                      isDraggable: false,
                      color: Colors.transparent,
                      controller: _pc2,
                      panel: DownloadPanel(
                          //panelController: _pc2,
                          downloadPanelController: _pc2,
                          info: info,
                          color: widget.myColor),
                      body: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(info['artUri'].toString()),
                                fit: BoxFit.cover)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ),
                          child: Container(
                            //color: widget.myColor.withOpacity(0.5),
                            //         color: isLightColor(snapshot.data![0])
                            // ? darken(snapshot.data![0], .2)
                            // : lighten(snapshot.data![0], .3)
                            color: isLightColor(widget.mostColor2)
                                ? darken(widget.mostColor2, .2).withOpacity(0.4)
                                : lighten(widget.mostColor2, .3)
                                    .withOpacity(0.4),
                            child: SingleChildScrollView(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          enableFeedback: false,
                                          icon: Icon(
                                            Icons.navigate_before,
                                            color: AppColors.white,
                                          ),
                                          splashRadius: 0.1,
                                          iconSize: 34.0,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.74,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'PLAYING FROM ALBUM',
                                                style: TextStyle(
                                                    fontSize: 11.0,
                                                    color: AppColors.white),
                                              ),
                                              SizedBox(height: 2.5),
                                              Text(
                                                info['album'],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _pc.open();
                                          },
                                          enableFeedback: false,
                                          icon: Image.asset(
                                              'assets/vertical_dots.png',
                                              height: 25.0,
                                              width: 25.0,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Container(
                                      margin: EdgeInsets.all(10.0),
                                      padding: EdgeInsets.all(10.0),
                                      // height: 380.0,
                                      // width: 380.0,
                                      child: CachedNetworkImage(
                                          imageUrl: info['artUri'].toString(),
                                          fit: BoxFit.cover),
                                    ),
                                    SizedBox(
                                      height: 18.0,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 20.0, right: 12.0),
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  info['title'],
                                                  style: TextStyle(
                                                      fontSize: 19.0,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: AppColors.white),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 2.5),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  child: Text(
                                                    info['artist'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: AppColors.white),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          FavoriteButton(
                                            myColor: widget.myColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Container(
                                      //decoration: BoxDecoration(color: widget.medianColor),
                                      //height: 3.0,
                                      padding: EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      child: SizedBox(
                                          //height: 2.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.96,
                                          child: AudioProgresssBar(
                                              myColor: widget.myColor)),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RepeatButton(
                                            myColor: widget.myColor,
                                          ),
                                          PreviousSongButton(
                                            myColor: widget.myColor,
                                          ),
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              child: Container(
                                                  height: 50.0,
                                                  width: 50.0,
                                                  color: isLightColor(
                                                          widget.myColor)
                                                      ? darken(
                                                          widget.myColor, .2)
                                                      : lighten(
                                                          widget.myColor, .3),
                                                  child: PlayButton(
                                                    myColor: widget.myColor,
                                                  ))),
                                          NextSongButton(
                                            myColor: widget.myColor,
                                          ),
                                          ShuffleButton(
                                            myColor: widget.myColor,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          FavoriteButton(
                                              myColor: widget.myColor),
                                          Share(
                                            test: widget.info['main_url'],
                                          )
                                        ],
                                      ),
                                    ),
                                    Builder(builder: (context) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            top: 15.0, left: 20.0, right: 20.0),
                                        //height: 320.0,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color: isLightColor(
                                                    widget.mostColor)
                                                ? darken(widget.mostColor, .2)
                                                : lighten(
                                                    widget.mostColor, .3)),
                                        child: Container(
                                          margin: EdgeInsets.fromLTRB(
                                              15.0, 5.0, 15.0, 15.0),
                                          child: ValueListenableBuilder(
                                              valueListenable: lyrics,
                                              builder: (context,
                                                  List<dynamic> data, _) {
                                                if (data.isNotEmpty &&
                                                    data.length > 2) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Lyrics',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 8.0),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50.0),
                                                              child: Container(
                                                                height: 30.0,
                                                                width: 30.0,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.25),
                                                                child: IconButton(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            0.0),
                                                                    onPressed:
                                                                        () {},
                                                                    icon: Image.asset(
                                                                        'assets/expand.png',
                                                                        height:
                                                                            13.0,
                                                                        width:
                                                                            13.0,
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      Container(
                                                          child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          lyricWidget(data[1]),
                                                          lyricWidget(data[2]),
                                                          lyricWidget(data[3]),
                                                          lyricWidget(data[4]),
                                                          lyricWidget(data[5]),
                                                          lyricWidget(data[6]),
                                                          lyricWidget(data[7])
                                                        ],
                                                      )),

                                                      SizedBox(height: 25.0),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child:
                                                                  Container()),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    25.0,
                                                                    5.0,
                                                                    25.0,
                                                                    5.0),
                                                            width: 115.0,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0)),
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/share2.png',
                                                                  height: 12.0,
                                                                  width: 12.0,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Text(
                                                                  'Share',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5.0,
                                                      )
                                                      //Positioned(child: IconButton(icon: Icon(Icons),))
                                                    ],
                                                  );
                                                } else
                                                  return Container(
                                                    height: 100.0,
                                                    margin: EdgeInsets.only(
                                                        top: 10.0),
                                                    child: Text(
                                                      'This song has no lyrics',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  );
                                              }),
                                        ),
                                      );
                                    }),
                                    SizedBox(height: 50.0)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({Key? key, required this.myColor}) : super(key: key);
  final Color myColor;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      width: 40.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {},
          //iconSize: 28.0,
          // icon: Icon(
          //   Icons.favorite_border,
          //   color: isLightColor(myColor)
          //       ? darken(myColor, .2)
          //       : lighten(myColor, .3),
          // )),
          icon: Image.asset(
            'assets/heart2.png',
            height: 24.0,
            width: 24.0,
            // color: isLightColor(myColor)
            //     ? darken(myColor, .2)
            //     : lighten(myColor, .3)
            color: Colors.white,
          )),
    );
  }
}

class AudioProgresssBar extends StatelessWidget {
  const AudioProgresssBar({Key? key, required this.myColor}) : super(key: key);
  final Color myColor;
  @override
  Widget build(BuildContext context) {
    final audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: audioManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          barHeight: 3.0,
          timeLabelLocation: TimeLabelLocation.below,
          timeLabelTextStyle: TextStyle(
              color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500),
          // thumbGlowRadius: 0.0,
          // thumbGlowColor: Colors.black,
          progress: value.current,
          //buffered: value.buffered,
          total: value.total,
          thumbRadius: 5.0,
          // thumbCanPaintOutsideBar: true,
          // progressBarColor: Colors.blue[300],
          // thumbColor: Colors.blue[300],
          progressBarColor: isLightColor(myColor)
              ? darken(myColor, .2)
              : lighten(myColor, .3),
          thumbColor: isLightColor(myColor)
              ? darken(myColor, .2)
              : lighten(myColor, .3),
          baseBarColor: AppColors.white.withOpacity(0.25),
          onSeek: audioManager.seek,
        );
      },
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key, required this.myColor}) : super(key: key);
  final Color myColor;
  @override
  Widget build(BuildContext context) {
    final audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder<RepeatState>(
      valueListenable: audioManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Widget icon;
        switch (value) {
          case RepeatState.off:
            icon = Image.asset('assets/repeat.png',
                height: 24.0, width: 24.0, color: Colors.white);
            break;
          case RepeatState.repeatSong:
            icon = Image.asset(
              'assets/repeat-once.png',
              height: 24.0,
              width: 24.0,
              color: isLightColor(myColor)
                  ? darken(myColor, .35)
                  : lighten(myColor, .3),
            );
            break;
          case RepeatState.repeatPlaylist:
            icon = Image.asset(
              'assets/repeat.png',
              height: 24.0,
              width: 24.0,
              color: isLightColor(myColor)
                  ? darken(myColor, .35)
                  : lighten(myColor, .3),
            );
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: audioManager.repeat,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key, required this.myColor}) : super(key: key);
  final Color myColor;
  @override
  Widget build(BuildContext context) {
    final audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: audioManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Image.asset(
            'assets/previous1.png',
            height: 20.0,
            width: 20.0,
            // color: isLightColor(myColor)
            //     ? darken(myColor, .2)
            //     : lighten(myColor, .3),
            color: Colors.white,
          ),
          onPressed: (isFirst) ? null : audioManager.previous,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key, required this.myColor}) : super(key: key);
  final Color myColor;
  @override
  Widget build(BuildContext context) {
    final audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: audioManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(16.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Image.asset('assets/play2.png',
                  height: 18.0, width: 18.0, color: Colors.white),
              //color: AppColors.white,
              //iconSize: 32.0,
              onPressed: audioManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 28.0,
              onPressed: audioManager.pause,
              color: AppColors.white,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key, required this.myColor}) : super(key: key);
  final Color myColor;
  @override
  Widget build(BuildContext context) {
    final audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: audioManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: Image.asset(
            'assets/next4.png',
            height: 20.0,
            width: 20.0,
            // color: isLightColor(myColor)
            //     ? darken(myColor, .2)
            //     : lighten(myColor, .3),
            color: Colors.white,
          ),
          onPressed: (isLast) ? null : audioManager.next,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key, required this.myColor}) : super(key: key);
  final Color myColor;
  @override
  Widget build(BuildContext context) {
    final audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: audioManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled)
              ? Image.asset(
                  'assets/shuffle4.png',
                  height: 24.0,
                  width: 24.0,
                  color: isLightColor(myColor)
                      ? darken(myColor, .35)
                      : lighten(myColor, .3),
                )
              : Image.asset(
                  'assets/shuffle4.png',
                  height: 24.0,
                  width: 24.0,
                  color: AppColors.white,
                ),
          onPressed: audioManager.shuffle,
        );
      },
    );
  }
}

class Share extends StatelessWidget {
  const Share({Key? key, required this.test}) : super(key: key);
  final String test;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      width: 32.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {
            //print('aaaaaaaaab ${test}');
          },
          //iconSize: 24.0,
          icon: Image.asset(
            'assets/share2.png',
            height: 19.0,
            width: 19.0,
            color: Colors.white,
          )),
      //icon: Icon(Icons.share)),
    );
  }
}

class QueueState {
  static const QueueState empty =
      QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(
    this.queue,
    this.queueIndex,
    this.shuffleIndices,
    this.repeatMode,
  );

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;
  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
      (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}

abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
  Future<void> moveQueueItem(int currentIndex, int newIndex);
  ValueStream<double> get volume;
  Future<void> setVolume(double volume);
  ValueStream<double> get speed;
}
