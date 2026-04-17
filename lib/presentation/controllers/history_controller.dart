import 'package:get/get.dart';
import '../../domain/entities/track_entity.dart';
import '../../domain/usecases/track_usecases.dart';

class HistoryController extends GetxController {
  final TrackUsecases _usecases = Get.find<TrackUsecases>();

  var tracks = <TrackEntity>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    final List<TrackEntity> result = await _usecases.fetchAllTracks();
    tracks.assignAll(result);
    isLoading.value = false;
  }
}
