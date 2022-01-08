import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Services/audio_manager.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rythm/app_color.dart' as AppColors;

class AlbumViewPanel extends StatelessWidget {
  const AlbumViewPanel({
    Key? key,
    //required this.controller,
    required this.panelController,
    //required this.downloadPanelController,
    required this.info,
    required this.color,
  }) : super(key: key);
  //final ScrollController controller;
  final PanelController panelController;
  //final PanelController downloadPanelController;
  final Song? info;
  //final String? mainUrl;
  final Color color;
  final String tempImage =
      'https://developers.google.com/maps/documentation/maps-static/images/error-image-generic.png?hl=vi';

  void _requestDownload(String link) async {
    final taskId = await FlutterDownloader.enqueue(
      url: link,
      savedDir: 'the path of directory where you want to save downloaded files',
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
      saveInPublicStorage: true,
    );
  }

  Future<void> requestDownload(String _url, String _name) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final dir = await getApplicationDocumentsDirectory();
      //From path_provider package
      var _localPath = dir.path + _name;
      final savedDir = Directory(_localPath);
      //print('aaaa ${savedDir}');
      await savedDir.create(recursive: true).then((value) async {
        String? _taskid = await FlutterDownloader.enqueue(
          url: _url,
          fileName: _name,
          savedDir: _localPath,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );
        //print(_taskid);
      });
    } else {
      print('Permission Denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AudioManager audioManager = GetIt.I<AudioManager>();
    return Container(
      decoration: BoxDecoration(color: AppColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              panelController.close();
            },
            child: Container(
              //margin: EdgeInsets.all(10.0),
              //padding: EdgeInsets.fromLTRB(100.0, 70.0, 100.0, 30.0),
              //height: 450.0,
              margin: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 54.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                              imageUrl: info?.songImage ?? tempImage,
                              fit: BoxFit.cover),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10.0, right: 15.0),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info?.songTitle ?? 'Null',
                              style: TextStyle(
                                  fontSize: 17.0, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5.0),
                            Text(info?.songSinger ?? 'Null',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: isLightColor(color) ? darken(color, .2) : lighten(color, .5),
            height: 10.0,
            thickness: 1.5,
            indent: 20.0,
            endIndent: 20.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    // String title = info?.songTitle ?? 'Null';
                    // String singer = info?.songSinger ?? 'Null';
                    // String _name = title + ' - ' + singer + '.flac';
                    // // requestDownload(
                    // //     info?.lossless ?? 'Null',
                    // //     info?.songTitle.toString() +
                    // //         ' - ' +
                    // //         info!.songSinger.toString() +
                    // //         '.flac');
                    // requestDownload(info?.lossless ?? 'Null', _name);
                    await audioManager.add(info!);
                    BotToast.showText(
                        text: "Added to queue",
                        textStyle:
                            TextStyle(fontSize: 15.0, color: Colors.white),
                        contentColor: Colors.black38,
                        contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 12),
                        borderRadius: BorderRadius.circular(30.0));
                  },
                  enableFeedback: false,
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 42.0,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        Text(
                          'Add to queue',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    audioManager.addNext(info!);
                    BotToast.showText(
                        text: "Added to next song",
                        textStyle:
                            TextStyle(fontSize: 15.0, color: Colors.white),
                        contentColor: Colors.black38,
                        contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 12),
                        borderRadius: BorderRadius.circular(30.0));
                  },
                  enableFeedback: false,
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 42.0,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        Text(
                          'Add to next broadcast',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w400),
                        ),
                        //SizedBox(width: 50.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Material(
              //   color: Colors.transparent,
              //   child: InkWell(
              //     onTap: () {},
              //     enableFeedback: false,
              //     splashColor: Colors.transparent,
              //     child: Container(
              //       height: 42.0,
              //       padding: EdgeInsets.only(left: 20.0),
              //       child: Row(
              //         children: [
              //           Text(
              //             'Medium (320 kbps)',
              //             style: TextStyle(fontSize: 16.0),
              //           ),
              //           SizedBox(width: 50.0),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // Material(
              //   color: Colors.transparent,
              //   child: InkWell(
              //     onTap: () {
              //       String title = info?.songTitle ?? 'Null';
              //       String singer = info?.songSinger ?? 'Null';
              //       String _name = title + ' - ' + singer + '.mp3';
              //       // requestDownload(
              //       //     info?.lossless ?? 'Null',
              //       //     info?.songTitle.toString() +
              //       //         ' - ' +
              //       //         info!.songSinger.toString() +
              //       //         '.flac');
              //       requestDownload(info?.lossless ?? 'Null', _name);
              //     },
              //     enableFeedback: false,
              //     splashColor: Colors.transparent,
              //     child: Container(
              //       height: 42.0,
              //       padding: EdgeInsets.only(left: 20.0),
              //       child: Row(
              //         children: [
              //           Text(
              //             'Normal (128 kbps)',
              //             style: TextStyle(fontSize: 16.0),
              //           ),
              //           SizedBox(width: 50.0),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
