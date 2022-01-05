import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rythm/Screens/AlbumDetails/album_page_header.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'dart:math' as math;
import 'package:rythm/app_color.dart' as AppColors;

class MyAppSpace extends StatelessWidget {
  const MyAppSpace(
      {Key? key,
      required this.title,
      required this.urlimage,
      required this.albumArtist,
      required this.color})
      : super(key: key);

  final String title;
  final String albumArtist;
  final String urlimage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        final deltaExtent = settings!.maxExtent - settings.minExtent;
        final t =
            (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
                .clamp(0.0, 1.0) as double;
        final fadeStart = 0.0;
        const fadeEnd = 1.0;
        final opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);

        final fadeStart1 = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
        const fadeEnd1 = 1.0;
        final opacity1 = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
        //print(Interval(0.4, fadeEnd).transform(t));
        // return FutureBuilder<Color>(
        //     future: getMedianColor(urlimage.toString()),

        //     //future: getImagePalette(NetworkImage(urlimage)),
        //     builder: (context, snapshot) {
        //       if ((snapshot.hasError) || (!snapshot.hasData)) {
        // return Container(
        //   child: Center(
        //     child: Container(
        //         height: 265.0,
        //         child: Center(child: CircularProgressIndicator())),
        //   ),
        // );
        //       }

        //     }
        //     );
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //     tileMode: TileMode.decal,
                //     begin: Alignment.topCenter,
                //     end: Alignment.bottomCenter,
                //     colors: [
                //       Colors.blue[500]!,
                //       Colors.blue[200]!
                //       //Color(0xFF121212)
                //     ],
                //     stops: [
                //       0.0,
                //       1.0
                //     ]),
                gradient: LinearGradient(
                    //tileMode: TileMode.decal,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isLightColor(color)
                          ? darken(color, .3)
                          : lighten(color, 0.1),
                      lighten(color, 0.4)
                      //Color(0xFF121212)
                    ],
                    stops: [
                      0.0,
                      1.0
                    ]),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.5),
                //     spreadRadius: 5,
                //     blurRadius: 7,
                //     offset: Offset(5, 5), // changes position of shadow
                //   ),
                // ],
              ),
              child: FlexibleSpaceBar(
                // background: getImage(urlimage, opacity),
                background: Container(
                  // decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //         begin: Alignment.topCenter,
                  //         end: Alignment.bottomCenter,
                  //         colors: [
                  //       Colors.blue.withOpacity(0.8),
                  //       Colors.blue.withOpacity(0.5),
                  //       //Color(0xFF121212)
                  //     ],
                  //         stops: [
                  //       0.0,
                  //       1.0
                  //     ])),
                  // padding: EdgeInsets.all(
                  //     20.0 / opacity < 45.0 ? 20.0 / opacity : 45.0),
                  // margin: EdgeInsets.only(
                  //     bottom: (1 - opacity) * 55.0, top: (1 - opacity) * 20.0),
                  margin: EdgeInsets.all(20.0),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scale(opacity > 0.5 ? opacity : 0.5),
                    child: CachedNetworkImage(
                      imageUrl: urlimage == ""
                          ? 'https://developers.google.com/maps/documentation/maps-static/images/error-image-generic.png?hl=vi'
                          : urlimage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 18.0,
              left: 50.0,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Opacity(
                opacity: 1 - opacity < 0.85
                    ? 0
                    : Interval(0.8, fadeEnd).transform(t) - opacity,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                      child: Text(title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              // color: isLightColor(snapshot.data!)
                              //     ? darken(snapshot.data!, .4)
                              color: lighten(color, 0.5))),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
