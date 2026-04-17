import 'package:get/get.dart';
import '../../data/datasources/local_database.dart';
import '../../data/repositories/track_repository_impl.dart';
import '../../domain/usecases/track_usecases.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LocalDatabase.instance, fenix: true);
    Get.lazyPut(() => TrackRepositoryImpl(Get.find<LocalDatabase>()), fenix: true);
    Get.lazyPut(() => TrackUsecases(Get.find<TrackRepositoryImpl>()), fenix: true);
  }
}
