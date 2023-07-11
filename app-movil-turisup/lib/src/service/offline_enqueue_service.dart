import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:turismup/src/model/post_new_comment_model.dart';
import 'package:turismup/src/model/post_new_place_model.dart';
import 'package:turismup/src/repository/place_api_repository.dart';
import 'package:turismup/src/repository/place_sembast_repository.dart';

import '../model/offline_enqueue_item_model.dart';
import '../repository/place_repository.dart';
import 'connectivity_utils.dart';

class OfflineEnqueueService {

  bool _serviceRunning = false;
   final PlaceRepository _repository=  GetIt.I.get();
   //ApiPlaceRepository apiPlaceRepository = ApiPlaceRepository();

  startService() async {

    // Service is already running
    if (_serviceRunning == true) return;

    // Should be online to process the queue
    if (await ConnectivityUtils.hasConnection() == false) return;

    _serviceRunning = true;

    // Search all the pending items in the queue

    var todosItems = await _repository.offlineGetByFilters(
        "PENDING",
    );

    // If the queue doesn't have any items the service is stopped

    if (todosItems.isEmpty) return;


    for (int i=0 ; i<todosItems.length ; i++) {

      if(todosItems[i].status ==  "PENDING"){
        try {
          // Mark enqueue item with the status PROCESSING
          await _repository.offlineChangeStatus(
            i,
            todosItems[i],
            "PROCESSING",
          );


          // Process enqueue item
          await _processItem(todosItems[i]);

          // Mark enqueue item with the status DONE
          await _repository.offlineChangeStatus(
            i,
            todosItems[i],
            "DONE",
          );
        } catch (ex) {
          await _repository.offlineChangeStatus(
              i,
              todosItems[i],
              "ERROR"
          );
        }
      }


    }

    _serviceRunning = false;

  }

  addToQueue(OfflineEnqueueItemModel model) async {
    var result = await _repository.offlineInsert(model);
    startService();
    print('result in addToQueue ${result}');
    return result;
  }

  _processItem(OfflineEnqueueItemModel model) async {

    switch (model.type) {

      case "INSERT_PLACE":
        Fluttertoast.showToast(msg: "Subiendo recurso...");
      int result = await _repository.insertPlace(PostNewPlaceModel.fromJson(model.data));
      print(result);
      if(result ==200){
        Fluttertoast.showToast(msg: "Recurso subido exitosamente");
      }else{
        Fluttertoast.showToast(msg: "Error en la subida");
      }
        break;
      case "INSERT_COMMENT":
        Fluttertoast.showToast(msg: "Subiendo comentario...");
        int result = await _repository.insertComment(PostNewCommentModel.fromJson(model.data));
        if(result ==200){
          Fluttertoast.showToast(msg: "Comentario subido exitosamente");
        }else{
          Fluttertoast.showToast(msg: "Error en la subida");
        }
        break;
      case "CREATE_ROUTE":
        break;
    }

  }
}