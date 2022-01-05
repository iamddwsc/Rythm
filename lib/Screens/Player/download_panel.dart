import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rythm/app_color.dart' as AppColors;

class DownloadPanel extends StatelessWidget {
  const DownloadPanel(
      {Key? key,
      // required this.controller,
      //required this.panelController,
      required this.downloadPanelController,
      required this.info,
      required this.color})
      : super(key: key);
  //final ScrollController controller;
  //final PanelController panelController;
  final PanelController downloadPanelController;
  final Map<dynamic, dynamic> info;
  final Color color;

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
    return Container(
      decoration: BoxDecoration(
          // gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [
          //   Colors.white.withOpacity(0.8),
          //   Colors.white,
          //   // Colors.white,
          //   // isLightColor(snapshot.data!)
          //   //                 ? darken(snapshot.data!, .4)
          //   //                 : lighten(snapshot.data!, 0.1),
          //   // lighten(widget.myColor, 0.4),
          //   // isLightColor(widget.myColor)
          //   //     ? darken(widget.myColor, .2)
          //   //     : lighten(widget.myColor, .3),
          //   // AppColors.white
          // ],
          //     stops: [
          //   0.0,
          //   // 0.7,
          //   0.1
          // ])),
          color: AppColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              downloadPanelController.close();
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
                              imageUrl: info['artUri'].toString(),
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
                              info['title'],
                              style: TextStyle(
                                  fontSize: 17.0, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5.0),
                            Text(info['artist'],
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
          SizedBox(
            height: 5.0,
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'Choose quality: ',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    requestDownload(info['lossless'],
                        info['title'] + ' - ' + info['artist'] + '.flac');
                  },
                  enableFeedback: false,
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 42.0,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        Text(
                          'Lossless (FLAC)',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 50.0),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  enableFeedback: false,
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 42.0,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        Text(
                          'High (500 kbps)',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(width: 50.0),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  enableFeedback: false,
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 42.0,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        Text(
                          'Medium (320 kbps)',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(width: 50.0),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    requestDownload(info['mp3_url_128'],
                        info['title'] + ' - ' + info['artist'] + '.mp3');
                  },
                  enableFeedback: false,
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 42.0,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        Text(
                          'Normal (128 kbps)',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(width: 50.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
