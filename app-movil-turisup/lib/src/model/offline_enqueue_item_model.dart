class OfflineEnqueueItemModel {
  final String type;
  String status;
  final dynamic data;

  OfflineEnqueueItemModel({
    required this.type,
    required this.status,
    this.data,
  });

  get id => null;

  static OfflineEnqueueItemModel formJson(json) => OfflineEnqueueItemModel(
    type: json["type"],
    status: json["status"],
    data: json["data"]
  );
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> myData = <String, dynamic>{};
    myData['type'] = type;
    myData['status'] = status;
    myData['data'] = data;
    return myData;
  }
}