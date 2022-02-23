class Station {
  late String stationName;
  late List<StationData> stationInfo;

  Station(this.stationName, this.stationInfo);

  Station.fromJson(Map<String, dynamic> json) {
    stationName = json['stationName'];
    if (json['data'] != null) {
      stationInfo = [];
      json['data'].forEach((v) {
        stationInfo.add(StationData.fromJson(v));
      });
    }
  }
}

class StationData {
  late String name;
  late String nodeId;
  late bool activate;

  StationData(this.name, this.nodeId, this.activate);

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
