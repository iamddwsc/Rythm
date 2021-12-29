import 'package:flutter/material.dart';
import 'package:rythm/Models/slider_info_model.dart';
import 'package:rythm/app_color.dart' as AppColors;

class SliderItemWidget extends StatelessWidget {
  const SliderItemWidget({
    Key? key,
    required this.sliderItem,
  }) : super(key: key);

  final SliderInfo? sliderItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final snackBar =
            SnackBar(content: Text(sliderItem!.sliderArtist ?? 'Null'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Column(
        children: [
          Container(
            child: Center(
              child: Image.network(
                sliderItem!.sliderImage ?? 'null',
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.8,
                height: 180.0,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(sliderItem!.sliderTitle ?? 'Null',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor),
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              sliderItem!.sliderArtist ?? 'Null',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.subTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}
