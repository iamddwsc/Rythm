import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rythm/Models/Boxes.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Screens/Player/player_screen.dart';
import 'package:rythm/Services/audio_manager.dart';
import 'package:rythm/Services/notifiers/play_button_notifier.dart';
import 'package:rythm/Services/notifiers/progress_notifier.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'package:rythm/Utils/custom_page_route.dart';
import 'package:rythm/app_color.dart' as AppColors;

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key, required this.info}) : super(key: key);
  //final int index;
  //final Color medianColor;
  final Map<dynamic, dynamic> info;
  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    //final ImageProvider imgProvider;
    final AudioManager audioManager = GetIt.I<AudioManager>();
    return FutureBuilder<List<Color>>(
        //initialData: Colors.transparent,
        future: getMedianColor(widget.info['artUri'].toString()),
        //future: getImagePalette(NetworkImage(widget.info['artUri'].toString())),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {}
          if (snapshot.hasData) {
            //print('OK2');
            return Container(
              decoration: BoxDecoration(
                color: isLightColor(snapshot.data![0])
                    ? darken(snapshot.data![0], .2)
                    : lighten(snapshot.data![0], .3),
              ),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 57.0,
                      child: Row(
                        children: [
                          Container(
                              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: CachedNetworkImage(
                                imageUrl: widget.info['artUri'].toString(),
                                fit: BoxFit.cover,
                              )),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => PlayerScreen()));
                              Navigator.of(context).push(CustomPageRoute(
                                  child: PlayerScreen(
                                      myColor: snapshot.data![0],
                                      mostColor: snapshot.data![1],
                                      mostColor2: snapshot.data![2],
                                      info: widget.info),
                                  direction: AxisDirection.up));
                            },
                            // onPanDown: (d) {
                            //   x1Prev = x1;
                            //   y1Prev = y1;
                            // },
                            // onPanUpdate: ,
                            // onHorizontalDragEnd: (DragEndDetails) {
                            //   //audioManager.next();
                            //   // final boxIndex = Boxes.getPlayingIndex();
                            //   // boxIndex.put('myPlayingIndex', widget.index + 1);
                            // },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.62,
                              padding: EdgeInsets.only(left: 5.0),
                              child: Container(
                                //height: 40.0,
                                // padding: EdgeInsets.only(bottom: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.info['title'].toString(),
                                      style: TextStyle(
                                          //fontSize: 24.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    //SizedBox(height: 1.0),
                                    Text(
                                      widget.info['artist'],
                                      overflow: TextOverflow.ellipsis,
                                      //textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              AppColors.white.withOpacity(0.7)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: Container()),
                          FavoriteButton(),
                          SizedBox(
                              height: 40.0, width: 40.0, child: PlayButton()),
                        ],
                      )),
                  // child: CurrentSong()),
                  Container(
                    //decoration: BoxDecoration(color: widget.medianColor),
                    //height: 3.0,
                    child: SizedBox(
                        //height: 2.0,
                        width: MediaQuery.of(context).size.width * 0.96,
                        child: AudioProgresssBar()),
                  )
                ],
              ),
            );
          } else {
            return Visibility(child: Container(), visible: false);
          }
        });
  }
}

class NextSongMiniPlayer extends StatelessWidget {
  const NextSongMiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('OKOKOKOK'),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      width: 40.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          //padding: const EdgeInsets.all(1.0),
          onPressed: () {},
          iconSize: 24.0,
          icon: Icon(
            Icons.favorite_border,
            color: AppColors.white,
          )),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AudioManager audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder(
        valueListenable: audioManager.playButtonNotifier,
        builder: (context, value, __) {
          switch (value) {
            case ButtonState.loading:
              return Container(
                margin: EdgeInsets.all(10.0),
                width: 28.0,
                height: 28.0,
                child: CircularProgressIndicator(),
              );
            case ButtonState.paused:
              return IconButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: audioManager.play,
                  iconSize: 28.0,
                  icon: Icon(
                    Icons.play_arrow,
                    color: AppColors.white,
                    //size: 32.0,
                  ));
            case ButtonState.playing:
              return IconButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: audioManager.pause,
                  iconSize: 28.0,
                  icon: Icon(
                    Icons.pause,
                    color: AppColors.white,
                    //size: 32.0,
                  ));
            default:
              return IconButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: audioManager.play,
                  iconSize: 28.0,
                  icon: Icon(
                    Icons.play_arrow,
                    color: AppColors.white,
                    //size: 32.0,
                  ));
          }
        });
  }
}

class AudioProgresssBar extends StatelessWidget {
  const AudioProgresssBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: audioManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          barHeight: 3.0,
          timeLabelLocation: TimeLabelLocation.none,

          // thumbGlowRadius: 0.0,
          // thumbGlowColor: Colors.black,
          progress: value.current,
          //buffered: value.buffered,
          total: value.total,
          thumbRadius: 0.0,
          // thumbCanPaintOutsideBar: true,
          progressBarColor: AppColors.white,
          thumbColor: AppColors.white,
          baseBarColor: AppColors.white.withOpacity(0.4),
          //onSeek: audioManager.seek,
        );
      },
    );
  }
}

class CurrentSong extends StatelessWidget {
  const CurrentSong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AudioManager audioManager = GetIt.I<AudioManager>();
    return ValueListenableBuilder(
        valueListenable: audioManager.currentSongNotifier,
        builder: (_, Map<dynamic, dynamic> info, __) {
          //print(info);
          return Row(
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
                  child: CachedNetworkImage(
                    imageUrl: info['artUri'].toString(),
                    fit: BoxFit.cover,
                  )),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                // onPanDown: (d) {
                //   x1Prev = x1;
                //   y1Prev = y1;
                // },
                // onPanUpdate: ,
                // onHorizontalDragEnd: (DragEndDetails) {
                //   //audioManager.next();
                //   // final boxIndex = Boxes.getPlayingIndex();
                //   // boxIndex.put('myPlayingIndex', widget.index + 1);
                // },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.only(left: 5.0, top: 8.0),
                  child: Container(
                    //height: 40.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info['title'].toString(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          info['artist'].toString(),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.subTitleText),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
              FavoriteButton(),
              SizedBox(height: 40.0, width: 40.0, child: PlayButton()),
            ],
          );
        });
  }
}
