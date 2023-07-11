import 'package:turismup/src/model/place_model.dart';

import '../model/offline_enqueue_item_model.dart';
import '../model/post_new_comment_model.dart';
import '../model/post_new_place_model.dart';

abstract class PlaceRepository{
  Future<int> insertPlace(PostNewPlaceModel newPlace);
  Future<List<PlaceModel>> getAllPlaces();
  Future saveAllPlaces(List<PlaceModel> places);
  Future deleteAllPlaces();
  Future<bool> getSavedPlaces();

  Future<int> insertComment(PostNewCommentModel newComment);

  Future<List<OfflineEnqueueItemModel>> offlineGetByFilters( String status);
  offlineChangeStatus(int index, OfflineEnqueueItemModel item, String s);
  offlineInsert(OfflineEnqueueItemModel model);

}