import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/storage_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Singletons
  await StorageService.init();
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  locator.registerSingleton<StorageService>(StorageService());

  // Services
  // locator.registerLazySingleton<ApiService>(() => ApiService());
  // locator.registerLazySingleton<AuthService>(() => AuthService());
  // locator.registerLazySingleton<DatabaseService>(() => DatabaseService());

  // Repositories
  // locator.registerLazySingleton<UserRepository>(() => UserRepository(locator()));

  // ViewModels/Blocs
  // locator.registerFactory<AuthBloc>(() => AuthBloc(locator()));
}
