/// connect : "test.ddns.net:3000"
/// projectName : "machine1"
/// use : true
/// data : [{"name":"총 생산량","nodeId":"ns=3;s=","value":true}]

class Project {
  Project({
      required String connect,
      required String projectName,
      required bool use,
      required List<Data> data,}){
    _connect = connect;
    _projectName = projectName;
    _use = use;
    _data = data;
}

  Project.fromJson(dynamic json) {
    _connect = json['connect'];
    _projectName = json['projectName'];
    _use = json['use'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data.add(Data.fromJson(v));
      });
    }
  }
  String _connect;
  String _projectName;
  bool _use;
  List<Data> _data;

  String get connect => _connect;
  String get projectName => _projectName;
  bool get use => _use;
  List<Data> get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['connect'] = _connect;
    map['projectName'] = _projectName;
    map['use'] = _use;
    if (_data != null) {
      map['data'] = _data.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// name : "총 생산량"
/// nodeId : "ns=3;s="
/// value : true

class Data {
  Data({
      required String name,
      required String nodeId,
      required bool value,}){
    _name = name;
    _nodeId = nodeId;
    _value = value;
}

  Data.fromJson(dynamic json) {
    _name = json['name'];
    _nodeId = json['nodeId'];
    _value = json['value'];
  }
  String _name;
  String _nodeId;
  bool _value;

  String get name => _name;
  String get nodeId => _nodeId;
  bool get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['nodeId'] = _nodeId;
    map['value'] = _value;
    return map;
  }

}