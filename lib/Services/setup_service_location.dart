import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:rythm/Services/audio_handler.dart';
import 'package:rythm/Services/audio_manager.dart';

Future<void> setupServiceLocator() async {
  // services
  GetIt.I.registerSingleton<AudioHandler>(await initAudioService());
  //GetIt.I.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());

  // page state
  GetIt.I.registerLazySingleton<AudioManager>(() => AudioManager());
}
