import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rythm/Models/album_details_model.dart';
import 'package:rythm/Models/album_homepage_model.dart';
import 'package:rythm/Screens/Player/player_screen.dart';
import 'package:rythm/Services/audio_manager.dart';
import 'package:rythm/Services/audio_service_impl.dart';
import 'package:rythm/Services/playlist_repository.dart';
import 'package:rythm/Services/setup_service_location.dart';
import 'package:rythm/screens/home.dart';
import 'package:rythm/app_color.dart' as AppColors;
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:audio_service/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SongAdapter());
  await Hive.openBox<Song>('playing');
  await Hive.openBox<int>('currentPlayingIndex');
  await Hive.openBox<String>('currentPlayingAlbum');
  //await startService();
  await setupServiceLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(Rythm());
}

Future<void> startService() async {
  final AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerServiceImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.ddwsc.rythm.channel.audio',
      androidNotificationChannelName: 'Rythm',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      // androidStopForegroundOnPause: Hive.box('settings')
      // .get('stopServiceOnPause', defaultValue: true) as bool,
      notificationColor: Colors.grey[900],
    ),
  );
  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  //GetIt.I.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());
  // page state
  GetIt.I.registerLazySingleton<AudioManager>(() => AudioManager());
}

class Rythm extends StatelessWidget {
  const Rythm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(primaryColor: Colors.black, fontFamily: 'Circular'),
      debugShowCheckedModeBanner: false,
      title: 'Rythm',
      home: Home(),
      // onGenerateRoute: (settings) {
      //   if (settings.name == 'check') {
      //     final args = settings.arguments as AlbumHomePage;
      //     return MaterialPageRoute(
      //         settings: settings,
      //         builder: (context) {
      //           return Container(child: Text(args.itemTitle!));
      //         });
      //   }
      // },
    );
  }
}
