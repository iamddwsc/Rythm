import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:rythm/APIs/api.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Search/search.dart';
import 'package:rythm/Utils/custom_page_route.dart';
import 'package:rythm/app_color.dart' as AppColors;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 15.0, top: 30.0, right: 15.0),
          // decoration: BoxDecoration(
          //   color: Color(0xFFf4f5fe),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                //margin: EdgeInsets.only(top: 30.0, left: 15.0),
                child: Text(
                  'Search',
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textColor),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                height: 50.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                    // border: Border.all(color: Colors.black),
                    color: AppColors.searchBar),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CustomPageRoute(
                        child: SearchLayout(), direction: AxisDirection.up));
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) => SearchLayout()));
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Icon(
                        Icons.search,
                        size: 32.0,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'Type something...',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
