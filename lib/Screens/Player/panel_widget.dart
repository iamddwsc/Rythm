import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rythm/app_color.dart' as AppColors;

class PanelWidget extends StatelessWidget {
  const PanelWidget(
      {Key? key,
      required this.controller,
      required this.panelController,
      required this.downloadPanelControler,
      required this.info,
      required this.color})
      : super(key: key);
  final ScrollController controller;
  final PanelController panelController;
  final PanelController downloadPanelControler;
  final Map<dynamic, dynamic> info;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Container(
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

                          // padding: EdgeInsets.all(5.0),
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
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w700),
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
              color:
                  isLightColor(color) ? darken(color, .2) : lighten(color, .5),
              height: 10.0,
              thickness: 1.5,
              indent: 20.0,
              endIndent: 20.0,
            ),
            Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        FavoriteButton(),
                        SizedBox(width: 10.0),
                        Text(
                          'Like',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: [
                        AddToPlaylist(),
                        SizedBox(width: 10.0),
                        Text(
                          'Add to playlist',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                    Divider(
                      color: isLightColor(color)
                          ? darken(color, .2)
                          : lighten(color, .5),
                      height: 10.0,
                      thickness: 1.5,
                    ),
                    SizedBox(height: 8.0),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        enableFeedback: false,
                        splashColor: Colors.transparent,
                        onTap: () {
                          panelController.close();
                          Future.delayed(Duration(milliseconds: 300), () {
                            downloadPanelControler.open();
                          });
                        },
                        //splashColor: Colors.blue,
                        child: Row(
                          children: [
                            Download(controller: downloadPanelControler),
                            SizedBox(width: 10.0),
                            Text(
                              'Download',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Share(),
                        SizedBox(width: 10.0),
                        Text(
                          'Share',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Artist(),
                        SizedBox(width: 10.0),
                        Text(
                          'Artist',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Report(),
                        SizedBox(width: 10.0),
                        Text(
                          'Report',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ],
                )),
            SizedBox(
              height: 45.0,
            )
          ],
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      width: 32.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {},
          //iconSize: 24.0,
          icon: Image.asset(
            'assets/heart2.png',
            height: 22.0,
            width: 22.0,
            color: Colors.black,
          )),
    );
  }
}

class AddToPlaylist extends StatelessWidget {
  const AddToPlaylist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      width: 32.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {},
          //iconSize: 24.0,
          icon: Image.asset(
            'assets/add_to_playlist4.png',
            height: 22.0,
            width: 22.0,
            color: Colors.black,
            isAntiAlias: true,
          )),
      //icon: Icon(Icons.playlist_add)),
    );
  }
}

class Download extends StatelessWidget {
  const Download({Key? key, required this.controller}) : super(key: key);
  final PanelController controller;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      width: 32.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {},
          //iconSize: 24.0,
          icon: Image.asset(
            'assets/download3.png',
            height: 19.0,
            width: 19.0,
            color: Colors.black,
          )),
      //icon: Icon(Icons.playlist_add)),
    );
  }
}

class Share extends StatelessWidget {
  const Share({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      width: 32.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {},
          //iconSize: 24.0,
          icon: Image.asset(
            'assets/share2.png',
            height: 20.0,
            width: 20.0,
            color: Colors.black,
          )),
      //icon: Icon(Icons.share)),
    );
  }
}

class Artist extends StatelessWidget {
  const Artist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      width: 32.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {},
          //iconSize: 24.0,
          icon: Image.asset(
            'assets/artist.png',
            height: 22.0,
            width: 22.0,
            color: Colors.black,
          )),
      //icon: Icon(Icons.share)),
    );
  }
}

class Report extends StatelessWidget {
  const Report({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      width: 32.0,
      //padding: EdgeInsets.all(5.0),
      child: IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {},
          //iconSize: 24.0,
          icon: Image.asset(
            'assets/report.png',
            height: 20.0,
            width: 20.0,
            color: Colors.black,
          )),
      //icon: Icon(Icons.share)),
    );
  }
}
