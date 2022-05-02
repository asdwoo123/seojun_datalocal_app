class Station {
  late String stationName;
  late String connectIp;
  bool isConnect = false;
  bool isCamera = true;
  bool isRemote = true;
  late List<StationData> stationInfo;
  late Map<String, dynamic> data;

  Station.fromJson(Map<String, dynamic> json) {
    stationName = json['stationName'];
    connectIp = json['connectIp'];
    isCamera = json['isCamera'];
    isRemote = json['isRemote'];
    if (json['stationData'] != null) {
      stationInfo = [];
      json['stationData'].forEach((v) {
        stationInfo.add(StationData.fromJson(v));
      });
    }
  }
}

class StationData {
  late String name;
  late String nodeId;
  late bool activate;

  StationData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nodeId = json['nodeId'];
    activate = json['value'];
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'nodeId': nodeId,
        'actiavte': activate
      };
}
