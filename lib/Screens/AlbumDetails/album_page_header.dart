import 'package:flutter/material.dart';
import 'package:rythm/Models/album_homepage_model.dart';
import 'package:rythm/app_color.dart' as AppColors;

class AlbumPageHeader extends StatefulWidget {
  const AlbumPageHeader(
      {Key? key,
      //required this.albumHomePage,
      required this.albumTitle,
      required this.albumArtist})
      : super(key: key);

  //final AlbumHomePage? albumHomePage;
  final String albumTitle;
  final String albumArtist;

  @override
  _AlbumPageHeaderState createState() => _AlbumPageHeaderState();
}

class _AlbumPageHeaderState extends State<AlbumPageHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Colors.blue[200]!,
            Colors.blue[100]!,
            Colors.white,
          ],
              stops: [
            0.0,
            0.7,
            1.0
          ])),
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Container(
          // decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //         colors: [
          //       Colors.black.withOpacity(0.8),
          //       // Colors.black.withOpacity(0.9),
          //       Colors.blue
          //     ],
          //         stops: [
          //       0.0,
          //       //0.25,
          //       1.0
          //     ])),
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 15.0, top: 5.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  // widget.albumHomePage!.itemTitle ?? 'Null',
                  widget.albumTitle,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 15.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.albumArtist,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white),
                ),
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: null,
                      icon:
                          Icon(Icons.favorite_outline, color: AppColors.white)),
                  IconButton(
                      onPressed: null,
                      icon: Icon(Icons.more_vert_outlined,
                          color: AppColors.white)),
                  Expanded(child: Container()),
                  // IconButton(
                  //     onPressed: null,
                  //     icon: Image.asset('assets/notification.png',
                  //         height: 26.0, width: 26.0, color: AppColors.textColor))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
