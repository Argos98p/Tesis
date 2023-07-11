import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import '../repository/place_repository.dart';
import '../repository/place_sembast_repository.dart';

class InitDatabaseSembast {
  static Future initialize() async {
    await _initSembast();
    _registerRepositories();
  }

  static Future _initSembast() async {
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    final databasePath = join(appDir.path, "sembast.db");
    final database = await databaseFactoryIo.openDatabase(databasePath);
    GetIt.I.registerSingleton<Database>(database);

  }
  static _registerRepositories(){
    GetIt.I.registerLazySingleton<PlaceRepository>(() => SembastPlaceRepository());
  }
}