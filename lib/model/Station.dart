class Station {
  late String stationName;
  late String connectIp;
  late List<StationData> stationInfo;
  late Map<String, dynamic> data;

  Station(this.stationName, this.connectIp, this.stationInfo);

  Station.fromJson(Map<String, dynamic> json) {
    stationName = json['stationName'];
    connectIp = json['connectIp'];
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
  late String type;
  late bool activate;

  StationData(this.name, this.nodeId, this.type, this.activate);

  StationData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nodeId = json['nodeId'];
    type = json['type'];
    activate = json['value'];
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'nodeId': nodeId,
        'type': type,
        'actiavte': activate
      };
}
