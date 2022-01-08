import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Models/boxes.dart';
import 'package:rythm/Screens/BottomNavBarSupport/tab_navigator.dart';
import 'package:rythm/Screens/Player/mini_player.dart';
import 'package:rythm/Search/search_page.dart';
import 'package:rythm/Services/audio_manager.dart';
import 'package:rythm/Utils/calc_median_color.dart';
import 'package:rythm/app_color.dart' as AppColors;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List? popularBooks;
  ScrollController? _scrollController;
  TabController? _tabController;
  String daySession = "Chào buổi sáng";

  TimeOfDay now = TimeOfDay.now();

  getTime() {
    if (now.hour >= 0 && now.hour <= 10) {
      daySession = "Chào buổi sáng";
    } else if (now.hour > 10 && now.hour < 13) {
      daySession = "Chào buổi trưa";
    } else if (now.hour >= 13 && now.hour <= 18) {
      daySession = "Chào buổi chiều";
    } else {
      daySession = "Chào buổi tối";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    GetIt.I<AudioManager>().init();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    getTime();
    // Hive.openBox<List<Song>>('playing');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Hive.close();
    GetIt.I<AudioManager>().dispose();
    super.dispose();
  }

  String _currentPage = "Page1";
  List<String> pageKeys = ["Page1", "Page2", "Page3"];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Page1": GlobalKey<NavigatorState>(),
    "Page2": GlobalKey<NavigatorState>(),
    "Page3": GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;

  void _selectTab(String tabItem, int index) {
    print(index);
    if (index != 1) {
      // _navigatorKeys["Page2"]!.currentState!.pushReplacement(MaterialPageRoute(
      //     maintainState: false, builder: (context) => SearchPage()));
      _navigatorKeys["Page2"]!.currentState!.maybePop();
    }
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AudioManager audioManager = GetIt.I<AudioManager>();
    return Container(
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            final isFirstRouteInCurrentTab =
                !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
            if (isFirstRouteInCurrentTab) {
              if (_currentPage != "Page1") {
                _selectTab("Page1", 1);

                return false;
              }
            }
            // let system handle back button if we're on the first route
            return isFirstRouteInCurrentTab;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBody: true,
            body: Container(
              // decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //         colors: [
              //       Colors.black.withOpacity(0.7),
              //       //Colors.black.withOpacity(0.9),
              //       //Color(0xFF121212)
              //       Colors.black
              //     ],
              //         stops: [
              //       0.0,
              //       //0.25,
              //       0.25
              //     ])),
              // decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //         colors: [
              //       Colors.blue[300]!,
              //       //Colors.black.withOpacity(0.9),
              //       //Color(0xFF121212)
              //       Colors.white
              //     ],
              //         stops: [
              //       0.0,
              //       //0.25,
              //       0.25
              //     ])),
              child: Stack(
                children: <Widget>[
                  _buildOffstageNavigator("Page1"),
                  _buildOffstageNavigator("Page2"),
                  _buildOffstageNavigator("Page3"),
                  ValueListenableBuilder(
                      valueListenable: audioManager.currentSongNotifier,
                      builder: (context, Map<dynamic, dynamic> info, _) {
                        //final index = box.get('myPlayingIndex');
                        //var colour_data = getMedianColor(info['artUri'].toString()).;
                        // print(
                        //     'aaaaaaaaaa info data ${info['title'].toString()}');
                        //print('OK');
                        if (info.isNotEmpty) {
                          // return FutureBuilder<Color>(
                          //     future: getMedianColor(info['artUri'].toString()),
                          //     builder: (context, snapshot) {
                          //       return snapshot.hasData
                          //           ? Positioned(
                          //               bottom: 57.0,
                          //               height: 60.0,
                          //               width:
                          //                   MediaQuery.of(context).size.width,
                          //               child: Container(
                          //                 //padding: EdgeInsets.only(left: 5.0, right: 5.0),
                          //                 child: Material(
                          //                     //elevation: 5.0,
                          //                     child: ValueListenableBuilder<
                          //                         Box<int>>(
                          //                   valueListenable:
                          //                       Boxes.getPlayingIndex()
                          //                           .listenable(),
                          //                   builder: (context, box, widget) {
                          //                     final index =
                          //                         box.get('myPlayingIndex');
                          //                     //print('aaaaaaaaaa ${index}');
                          //                     //print(index);
                          //                     // if (index != Null) {
                          //                     //   return MiniPlayer(index: index);
                          //                     // } else
                          //                     //   return Divider();
                          //                     if (index != null) {
                          //                       return MiniPlayer(
                          //                           index: index,
                          //                           medianColor:
                          //                               snapshot.data!);
                          //                     } else {
                          //                       return Visibility(
                          //                           child: Container(),
                          //                           visible: false);
                          //                     }
                          //                   },
                          //                 )),
                          //               ))
                          //           : Visibility(
                          //               child: Container(), visible: false);
                          //     });
                          return Positioned(
                              bottom: 56.0,
                              height: 60.0,
                              width: MediaQuery.of(context).size.width,
                              // child: Container(
                              //   //padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              //   child: Material(
                              //       //elevation: 5.0,
                              //       child: ValueListenableBuilder<Box<int>>(
                              //     valueListenable:
                              //         Boxes.getPlayingIndex().listenable(),
                              //     builder: (context, box, widget) {
                              //       final index = box.get('myPlayingIndex');
                              //       //print('aaaaaaaaaa ${index}');
                              //       //print(index);
                              //       // if (index != Null) {
                              //       //   return MiniPlayer(index: index);
                              //       // } else
                              //       //   return Divider();
                              //       if (index != null) {
                              //         return MiniPlayer(
                              //             index: index, info: info);
                              //       } else {
                              //         return Visibility(
                              //             child: Container(), visible: false);
                              //       }
                              //     },
                              //   )),
                              // ));
                              child: MiniPlayer(info: info));
                        } else {
                          return Visibility(child: Container(), visible: false);
                        }
                      }),
                  // Builder(builder: (context) {
                  //   var checkPlaying = Boxes.getPlayingIndex();
                  //   var index = checkPlaying.get('myPlayingIndex');
                  //   if (index != null) {
                  //     return Positioned(
                  //         bottom: 57.0,
                  //         height: 60.0,
                  //         width: MediaQuery.of(context).size.width,
                  //         child: Container(
                  //           //padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  //           child: Material(
                  //               //elevation: 5.0,
                  //               child: ValueListenableBuilder<Box<int>>(
                  //             valueListenable:
                  //                 Boxes.getPlayingIndex().listenable(),
                  //             builder: (context, box, widget) {
                  //               final index = box.get('myPlayingIndex');
                  //               print('aaaaaaaaaa ${index}');
                  //               //print(index);
                  //               // if (index != Null) {
                  //               //   return MiniPlayer(index: index);
                  //               // } else
                  //               //   return Divider();
                  //               if (index != null) {
                  //                 return MiniPlayer(index: index);
                  //               } else {
                  //                 return Divider();
                  //               }
                  //             },
                  //           )),
                  //         ));
                  //   } else {
                  //     if (index != null) {
                  //       return Visibility(child: Container(), visible: true);
                  //     } else {
                  //       return Visibility(child: Container(), visible: false);
                  //     }
                  //   }
                  // })
                ],
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.4),
                  Colors.blue[200]!,
                  //Colors.black.withOpacity(1.0)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                tileMode: TileMode.decal,
              )),
              // color: Colors.black.withOpacity(0.8),
              child: BottomNavigationBar(
                elevation: 0.0,
                backgroundColor: Color(0x35000000),
                selectedItemColor: AppColors.white,
                unselectedItemColor: AppColors.sliverBackground,
                // selectedLabelStyle: TextStyle(
                //     fontFamily: 'Gotham',
                //     color: AppColors.white,
                //     fontWeight: FontWeight.w600),
                onTap: (int index) {
                  _selectTab(pageKeys[index], index);
                },
                currentIndex: _selectedIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                      color: AppColors.white,
                    ),
                    label: 'Trang chủ',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search, color: AppColors.white),
                    label: 'Tìm kiếm',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.library_music, color: AppColors.white),
                    label: 'Thư viện',
                  ),
                ],
                type: BottomNavigationBarType.fixed,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
        daySession: daySession,
      ),
    );
  }
}
