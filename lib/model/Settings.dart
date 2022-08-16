import 'package:flutter/cupertino.dart';

class Settings {
  String domain = '';
  String endpoint = '';
  String ip = '';
  int port = 3000;
  bool camera = true;
  late Pantilt pantilt;
  late Remote remote;
  late Save save;
  List<Node> node = [];
  TextEditingController domainController = TextEditingController();
  TextEditingController endpointController = TextEditingController();
  TextEditingController portController = TextEditingController();

  Settings.fromJson(Map<String, dynamic> json) {
    domain = json['domain'];
    endpoint = json['endpoint'];
    ip = json['ip'];
    port = json['port'];
    camera = json['camera'];
    pantilt = Pantilt.fromJson(json['pantilt']);
    remote = Remote.fromJson(json['remote']);
    save = Save.fromJson(json['save']);
    if (json['node'] != null) {
      json['node'].forEach((v) {
        node.add(Node.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() =>
      {'domain': domain, 'endpoint': endpoint, 'port': port, 'camera': camera, 'pantilt': pantilt.toJson(), 'remote': remote.toJson(), 'save': save.toJson(),
      'node': node.map((e) => e.toJson()).toList()};
}

class Pantilt {
  bool active = true;
  int length = 10;
  int speed = 1000;
  TextEditingController lengthController = TextEditingController();
  TextEditingController speedController = TextEditingController();

  Pantilt.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    length = json['length'];
    speed = json['speed'];
  }

  Map<String, dynamic> toJson() =>
      {'active': active, 'length': length, 'speed': speed};
}

class Remote {
  bool active = true;
  String start = '';
  String reset = '';
  String stop = '';
  String light = '';
  TextEditingController startController = TextEditingController();
  TextEditingController resetController = TextEditingController();
  TextEditingController stopController = TextEditingController();
  TextEditingController lightController = TextEditingController();

  Remote.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    start = json['start'];
    reset = json['reset'];
    stop = json['stop'];
    light = json['light'];
  }

  Map<String, dynamic> toJson() =>
      {'active': active, 'start': start, 'reset': reset, 'stop': stop, 'light': light};
}

class Save {
  bool active = true;
  String table = '';
  String complete = '';
  List<Field> fields = [];
  TextEditingController tableController = TextEditingController();
  TextEditingController completeController = TextEditingController();

  Save.fromJson(Map<String, dynamic> json) {
   active = json['active'];
    table = json['table'];
    complete = json['complete'];
    if (json['fields'] != null) {
      json['fields'].forEach((v) {
        fields.add(Field.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() =>
      {'active': active, 'table': table, 'complete': complete, 'fields': fields.map((e) => e.toJson()).toList()};
}

class Field {
  String name = '';
  String nodeId = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController nodeIdController = TextEditingController();

  Field.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nodeId = json['nodeId'];
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'nodeId': nodeId};
}

class Node {
  String name = '';
  String nodeId = '';
  bool active = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController nodeIdController = TextEditingController();

  Node.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nodeId = json['nodeId'];
    active = json['value'];
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'nodeId': nodeId, 'active': active};
}
