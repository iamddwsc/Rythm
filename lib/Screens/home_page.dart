import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rythm/APIs/api.dart';
import 'package:rythm/APIs/api_services.dart';
import 'package:rythm/CustomWidgets/general_horizontal_album_widget.dart';
import 'package:rythm/CustomWidgets/slider_item_widget.dart';
import 'dart:math' as math;
import 'package:rythm/app_color.dart' as AppColors;

import 'package:rythm/Models/slider_info_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.daySession}) : super(key: key);
  final String daySession;

  //final String daySession = "Chào buổi chiều";

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: AppColors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                  left: 10.0, top: 20.0, right: 5.0, bottom: 5.0),
              child: Row(
                children: [
                  Container(
                    //padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(daySession,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor)),
                  ),
                  const Expanded(child: Divider()),
                  IconButton(
                      onPressed: null,
                      icon: Image.asset('assets/notification.png',
                          height: 28.0,
                          width: 28.0,
                          color: AppColors.textColor)),
                  Transform.rotate(
                    angle: -20 * math.pi / 180,
                    child: IconButton(
                        onPressed: null,
                        icon: Image.asset(
                          'assets/history.png',
                          height: 26.0,
                          width: 26.0,
                          color: AppColors.textColor,
                        )),
                  ),
                  Transform.rotate(
                    angle: 20 * math.pi / 180,
                    child: IconButton(
                        onPressed: null,
                        icon: Image.asset(
                          'assets/setting.png',
                          height: 26.0,
                          width: 26.0,
                          color: AppColors.textColor,
                        )),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<SliderInfo>>(
                future: ApiServices().fetchSlider(),
                builder: (context, snapshot) {
                  if ((snapshot.hasError) || (!snapshot.hasData)) {
                    return Container(
                      child: Center(
                        child: Container(
                            height: 265.0,
                            child: Center(child: CircularProgressIndicator())),
                      ),
                    );
                  }
                  List<SliderInfo>? sliderList = snapshot.data;
                  return CarouselSlider.builder(
                      itemCount: sliderList?.length,
                      itemBuilder: (context, index, realIdx) {
                        return SliderItemWidget(sliderItem: sliderList?[index]);
                      },
                      options: CarouselOptions(
                        height: 265,
                        initialPage: 0,
                        enlargeCenterPage: true,
                      ));
                }),
            GeneralHorizontalAlbumWidget(
                country: RythmAPI().NEW_ALBUM_VN, albumTitle: 'Album VN 2021'),
            GeneralHorizontalAlbumWidget(
                country: RythmAPI().NEW_ALBUM_USUK,
                albumTitle: 'Album USUK 2021'),
            GeneralHorizontalAlbumWidget(
                country: RythmAPI().NEW_ALBUM_KR, albumTitle: 'Album KR 2021'),
            GeneralHorizontalAlbumWidget(
                country: RythmAPI().NEW_ALBUM_JP, albumTitle: 'Album JP 2021'),
            GeneralHorizontalAlbumWidget(
                country: RythmAPI().NEW_ALBUM_CN, albumTitle: 'Album CN 2021'),
            GeneralHorizontalAlbumWidget(
                country: RythmAPI().NEW_ALBUM_Other,
                albumTitle: 'Other Album 2021'),
            Container(
              height: 100.0,
            )
          ],
        ),
      ),
    );
  }
}
