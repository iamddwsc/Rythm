import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rythm/Screens/home_page.dart';
import 'package:rythm/Screens/local_songs.dart';
import 'package:rythm/Screens/search_page.dart';
import 'package:rythm/screens/home.dart';

class CupertinoStoreHomePage extends StatefulWidget {
  @override
  State<CupertinoStoreHomePage> createState() => _CupertinoStoreHomePageState();
}

class _CupertinoStoreHomePageState extends State<CupertinoStoreHomePage> {
  final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();

  final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();

  final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();

  CupertinoTabController? tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = CupertinoTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    final listOfKeys = [firstTabNavKey, secondTabNavKey, thirdTabNavKey];

    List homeScreenList = [HomePage(), SearchPage(), LocalSongsPage()];
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          return !await listOfKeys[tabController!.index]
              .currentState!
              .maybePop();
        },
        child: CupertinoTabScaffold(
          controller: tabController,
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.album_outlined),
                label: 'Local Songs',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              navigatorKey: listOfKeys[
                  index], //set navigatorKey here which was initialized before
              builder: (context) {
                return homeScreenList[index];
              },
            );
            // switch (index) {
            //   case 0:
            //     return CupertinoTabView(builder: (context) {
            //       return CupertinoPageScaffold(
            //         child: HomePage(),
            //       );
            //     });
            //   case 1:
            //     return CupertinoTabView(builder: (context) {
            //       return CupertinoPageScaffold(
            //         child: SearchPage(),
            //       );
            //     });
            //   case 2:
            //     return CupertinoTabView(builder: (context) {
            //       return CupertinoPageScaffold(
            //         child: LocalSongsPage(),
            //       );
            //     });
            //   default:
            //     return CupertinoTabView(builder: (context) {
            //       return CupertinoPageScaffold(
            //         child: HomePage(),
            //       );
            //     });
            // }
          },
        ),
      ),
    );
  }
}
