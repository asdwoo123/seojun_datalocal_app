import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:seojun_datalocal_app/model/Settings.dart';
import 'package:seojun_datalocal_app/pages/manual.dart';

import '../components/Custom_FormField.dart';
import '../components/Custom_label.dart';
import '../theme.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _connectIp = '';
  String _password = '';
  String ip = '';
  int mode = 1;
  Settings? _settingsData = null;
  final TextEditingController _connectIpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _connectSettings() async {
    bool notDomain = _connectIp.contains(":");
    mode = notDomain ? 2 : 1;
    var url = (notDomain) ? 'http://' + _connectIp + '/settings' : 'https://' + _connectIp + '.loca.lt/settings';
    var res = await http.read(Uri.parse(url));
    var parsed = json.decode(res);
    setState(() {
      _settingsData = Settings.fromJson(parsed);
      _settingsData?.domainController.text = _settingsData!.domain;
      _settingsData?.endpointController.text = _settingsData!.endpoint;
      _settingsData?.portController.text = _settingsData!.port.toString();
      _settingsData?.node.forEach((e) {
        e.nameController.text = e.name;
        e.nodeIdController.text = e.nodeId;
      });
      _settingsData?.pantilt.lengthController.text =
          _settingsData!.pantilt.length.toString();
      _settingsData?.pantilt.speedController.text =
          _settingsData!.pantilt.speed.toString();
      _settingsData?.remote.startController.text = _settingsData!.remote.start;
      _settingsData?.remote.resetController.text = _settingsData!.remote.reset;
      _settingsData?.remote.stopController.text = _settingsData!.remote.stop;
      _settingsData?.save.tableController.text = _settingsData!.save.table;
      _settingsData?.save.completeController.text =
          _settingsData!.save.complete;
      _settingsData?.save.fields.forEach((field) {
        field.nameController.text = field.name;
        field.typeController.text = field.type;
      });
    });
  }

  void _saveSettings() async {
    if (_settingsData!.pantilt.active) {
      var speed = _settingsData!.pantilt.speed;
      var length = _settingsData!.pantilt.length;
    }

    bool notDomain = _connectIp.contains(":");
    mode = notDomain ? 2 : 1;
    var url = (notDomain) ? 'http://' + _connectIp + '/settings' : 'https://' + _connectIp + '.loca.lt/settings';

    http.Response res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'max-connection-per-host': '5'
        },
        body: jsonEncode(
            {'password': _password, 'settings': _settingsData!.toJson()}));
    var parsed = json.decode(res.body);
    var success = parsed['success'];
    if (success) {
      Fluttertoast.showToast(msg: '저장되었습니다.');
    } else {
      Fluttertoast.showToast(msg: '저장에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(''),
            elevation: 0.0,
            backgroundColor: Colors.white,
            /*leading: GestureDetector(
              child: const Icon(
                Icons.close,
                color: Colors.black,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),*/
            actions: [
              /*TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ManualPage()));
                  },
                  child: const Text(
                    'Help',
                    style: TextStyle(color: Colors.black),
                  )),*/
              TextButton(
                  onPressed: _saveSettings,
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.black),
                  ))
            ]),
        body: Container(
          padding: EdgeInsets.all(20.0),
          color: const Color(0xfff2f2f2),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: ListBody(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomLabel(text: 'IP'),
                    ),
                    Expanded(
                        flex: 2,
                        child: CustomFormField(
                            controller: _connectIpController,
                            onChange: (value) {
                              setState(() {
                                _connectIp = value;
                              });
                            },
                            onPressed: () {
                              setState(() {
                                _connectIp = '';
                              });
                            })),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Expanded(flex: 1, child: CustomLabel(text: 'Password')),
                    Expanded(
                        flex: 2,
                        child: CustomFormField(
                            password: true,
                            controller: _passwordController,
                            onChange: (value) {
                              setState(() {
                                _password = value;
                              });
                            },
                            onPressed: () {
                              setState(() {
                                _password = '';
                              });
                            })),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        _connectSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Connect',
                        style: TextStyle(fontSize: 16),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                (_settingsData != null)
                    ? Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: Text('Domain'),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: CustomFormField(
                                      controller:
                                      _settingsData!.domainController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.domain = value;
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.domain = '';
                                        });
                                      })),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text('EndPoint'),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: CustomFormField(
                                      controller:
                                          _settingsData!.endpointController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.endpoint = value;
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.endpoint = '';
                                        });
                                      })),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(child: Text('Port')),
                              Expanded(
                                  child: CustomFormField(
                                      controller: _settingsData!.portController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.port =
                                              int.parse(value);
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.port = 0;
                                        });
                                      })),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(child: Text('Camera')),
                              Spacer(),
                              Switch(
                                  value: _settingsData!.camera,
                                  onChanged: (value) {
                                    setState(() {
                                      _settingsData!.camera = value;
                                    });
                                  })
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Pantilt',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              Text('active'),
                              Spacer(),
                              Switch(
                                  value: _settingsData!.pantilt.active,
                                  onChanged: (value) {
                                    setState(() {
                                      _settingsData!.pantilt.active = value;
                                    });
                                  })
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Text('Length')),
                              Expanded(
                                  child: CustomFormField(
                                      number: true,
                                      controller: _settingsData!
                                          .pantilt.speedController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.pantilt.length =
                                              int.parse(value);
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.pantilt.length = 0;
                                        });
                                      })),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Text('Speed')),
                              Expanded(
                                  child: CustomFormField(
                                    number: true,
                                      controller: _settingsData!
                                          .pantilt.speedController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.pantilt.speed =
                                              int.parse(value);
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.pantilt.speed = 0;
                                        });
                                      }))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Remote',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              Text('active'),
                              Spacer(),
                              Switch(
                                  value: _settingsData!.remote.active,
                                  onChanged: (value) {
                                    setState(() {
                                      _settingsData!.remote.active = value;
                                    });
                                  })
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Text('start')),
                              Expanded(
                                  flex: 2,
                                  child: CustomFormField(
                                      controller:
                                          _settingsData!.remote.startController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.remote.start = value;
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.remote.start = '';
                                        });
                                      }))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Text('reset')),
                              Expanded(
                                  flex: 2,
                                  child: CustomFormField(
                                      controller:
                                          _settingsData!.remote.resetController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.remote.reset = value;
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.remote.reset = '';
                                        });
                                      }))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Text('stop')),
                              Expanded(
                                  flex: 2,
                                  child: CustomFormField(
                                      controller:
                                          _settingsData!.remote.stopController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.remote.stop = value;
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.remote.stop = '';
                                        });
                                      }))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              Text('active'),
                              Spacer(),
                              Switch(
                                  value: _settingsData!.save.active,
                                  onChanged: (value) {
                                    setState(() {
                                      _settingsData!.save.active = value;
                                    });
                                  })
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Text('Table')),
                              Expanded(
                                  flex: 2,
                                  child: CustomFormField(
                                      controller:
                                          _settingsData!.save.tableController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.save.table = value;
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.save.table = '';
                                        });
                                      }))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Text('Complete')),
                              Expanded(
                                  flex: 2,
                                  child: CustomFormField(
                                      controller: _settingsData!
                                          .save.completeController,
                                      onChange: (value) {
                                        setState(() {
                                          _settingsData!.save.complete = value;
                                        });
                                      },
                                      onPressed: () {
                                        setState(() {
                                          _settingsData!.save.complete = '';
                                        });
                                      })),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                'Field',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _settingsData!.save.fields.add(
                                        Field.fromJson(
                                            {'name': '', 'type': ''}));
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                    primary: primaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: primaryBlue)),
                                child: Row(
                                  children: const <Widget>[
                                    Icon(Icons.add),
                                    Text('ADD')
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children:
                                _settingsData!.save.fields.map<Widget>((e) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () {
                                          var index = _settingsData!.save.fields
                                              .indexOf(e);
                                          setState(() {
                                            _settingsData!.save.fields
                                                .removeAt(index);
                                          });
                                        },
                                        color: Colors.red,
                                        icon:
                                            Icon(Icons.remove_circle_outline)),
                                    Expanded(
                                        flex: 2,
                                        child: CustomFormField(
                                            controller: e.nameController,
                                            onChange: (value) {
                                              setState(() {
                                                e.name = value;
                                              });
                                            },
                                            onPressed: () {
                                              setState(() {
                                                e.name = '';
                                              });
                                            })),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: CustomFormField(
                                            controller: e.typeController,
                                            onChange: (value) {
                                              setState(() {
                                                e.type = value;
                                              });
                                            },
                                            onPressed: () {
                                              setState(() {
                                                e.type = '';
                                              });
                                            })),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                'Node',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _settingsData!.node.add(Node.fromJson({
                                      'name': '',
                                      'nodeId': '',
                                      'value': true
                                    }));
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                    primary: primaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: primaryBlue)),
                                child: Row(
                                  children: const <Widget>[
                                    Icon(Icons.add),
                                    Text('ADD')
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: _settingsData!.node.map((e) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () {
                                          var index =
                                              _settingsData!.node.indexOf(e);
                                          setState(() {
                                            _settingsData!.node.removeAt(index);
                                          });
                                        },
                                        color: Colors.red,
                                        icon:
                                            Icon(Icons.remove_circle_outline)),
                                    Expanded(
                                        flex: 2,
                                        child: CustomFormField(
                                            controller: e.nameController,
                                            onChange: (value) {
                                              setState(() {
                                                e.name = value;
                                              });
                                            },
                                            onPressed: () {
                                              setState(() {
                                                e.name = '';
                                              });
                                            })),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: CustomFormField(
                                            controller: e.nodeIdController,
                                            onChange: (value) {
                                              setState(() {
                                                e.nodeId = value;
                                              });
                                            },
                                            onPressed: () {
                                              setState(() {
                                                e.nodeId = '';
                                              });
                                            }))
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        ));
  }
}
