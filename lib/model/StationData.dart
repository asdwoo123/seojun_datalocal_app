/// name : "총 생산량"
/// nodeId : "ns=3;s="
/// path : "a"
/// type : "int"
/// value : true

class StationData {
  StationData({
      String name, 
      String nodeId, 
      String path, 
      String type, 
      bool value,}){
    _name = name;
    _nodeId = nodeId;
    _path = path;
    _type = type;
    _value = value;
}

  StationData.fromJson(dynamic json) {
    _name = json['name'];
    _nodeId = json['nodeId'];
    _path = json['path'];
    _type = json['type'];
    _value = json['value'];
  }
  String _name;
  String _nodeId;
  String _path;
  String _type;
  bool _value;

  String get name => _name;
  String get nodeId => _nodeId;
  String get path => _path;
  String get type => _type;
  bool get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['nodeId'] = _nodeId;
    map['path'] = _path;
    map['type'] = _type;
    map['value'] = _value;
    return map;
  }

}