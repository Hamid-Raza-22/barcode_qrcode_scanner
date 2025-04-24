import 'package:get_it/get_it.dart';
import 'Repositories/scanner_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => ScannerRepository());
  // getIt.registerFactory(() => ScannerViewModel(repository: getIt<ScannerRepository>()));
}