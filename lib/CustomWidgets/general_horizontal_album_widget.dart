import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rythm/APIs/api_services.dart';
import 'package:rythm/Models/album_homepage_model.dart';
import 'package:rythm/Screens/AlbumDetails/album_details_widget.dart';
import 'package:rythm/app_color.dart' as AppColors;

class GeneralHorizontalAlbumWidget extends StatelessWidget {
  const GeneralHorizontalAlbumWidget(
      {Key? key, required this.country, required this.albumTitle})
      : super(key: key);

  final String? country;
  final String? albumTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, bottom: 30.0),
      child: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      albumTitle ?? 'Null',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor),
                    ),
                  ),
                  Expanded(child: Container()),
                  Container(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          color: AppColors.textColor),
                    ),
                  ),
                  Container(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: AppColors.textColor,
                        )),
                  )
                ],
              )),
          FutureBuilder<List<AlbumHomePage>>(
              future: ApiServices().fetchAlbumHomePage(country ?? 'null'),
              builder: (context, snapshot) {
                if ((snapshot.hasError) || (!snapshot.hasData)) {
                  return Container(
                    height: 180.0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                List<AlbumHomePage>? albumHomePage = snapshot.data;
                return SizedBox(
                  height: 180,
                  child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: albumHomePage?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return HorizontalAlbumWidget(
                            albumHomePage: albumHomePage?[index]);
                      }),
                );
              }),
        ],
      ),
    );
  }
}

class HorizontalAlbumWidget extends StatelessWidget {
  const HorizontalAlbumWidget({
    Key? key,
    required this.albumHomePage,
  }) : super(key: key);

  final AlbumHomePage? albumHomePage;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.only(right: 15.0),
      child: Column(
        children: [
          SizedBox(
            width: 150.0,
            height: 180.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  top: -30,
                  child: CachedNetworkImage(
                      height: 100,
                      imageUrl: albumHomePage!.itemImage == ""
                          ? 'https://developers.google.com/maps/documentation/maps-static/images/error-image-generic.png?hl=vi'
                          : albumHomePage!.itemImage!,
                      // errorWidget: (context, url, error) => Text("error"),
                      // imageBuilder: (context, imageProvider) =>
                      //     Image.asset('assets/error_image.png'),
                      fit: BoxFit.contain),
                ),
                Positioned.fill(
                  bottom: -160,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      albumHomePage!.itemArtist ?? "Null",
                      style: TextStyle(
                          color: AppColors.subTextColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Positioned.fill(
                    child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      // final snackBar = SnackBar(
                      //     content: Text(albumHomePage!.itemHref ?? 'Null'));
                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AlbumDetails(
                                albumHomePage: albumHomePage,
                              )));
                    },
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
