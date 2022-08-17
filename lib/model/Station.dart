class Station {
  late String stationName;
  late String connectIp;
  bool isProxy = false;
  bool isConnect = false;
  bool isCamera = true;
  bool isRemote = true;
  late List<StationData> stationInfo = [];
  late Map<String, dynamic> data = {};

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

  static List<StationData> fromInfo(List node) {
    List<StationData> si = [];
    node.forEach((v) {
      si.add(StationData.fromJson(v));
    });

    return si;
  }
}

class StationData {
  late String name;
  late String nodeId;

  StationData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nodeId = json['nodeId'];
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'nodeId': nodeId};
}
