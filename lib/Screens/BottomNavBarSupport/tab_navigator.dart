import 'package:flutter/material.dart';
import 'package:rythm/Screens/home.dart';
import 'package:rythm/Screens/home_page.dart';
import 'package:rythm/Screens/local_songs.dart';
import 'package:rythm/Screens/search_page.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? tabItem;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (tabItem == "Page1")
      child = HomePage();
    else if (tabItem == "Page2")
      child = SearchPage();
    else if (tabItem == "Page3") child = LocalSongsPage();

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child ?? Home());
      },
    );
  }
}
