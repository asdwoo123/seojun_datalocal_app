import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:seojun_datalocal_app/components/Custom_FormField.dart';
import 'package:seojun_datalocal_app/components/Custom_label.dart';
import 'package:seojun_datalocal_app/model/Settings.dart';
import 'package:seojun_datalocal_app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seojun_datalocal_app/service/index.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:flutter_nsd/flutter_nsd.dart';
import 'package:toast/toast.dart';


class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  String _stationName = '';
  String _connectIp = '';
  String _password = '';
  bool _isCamera = true;
  bool _isRemote = true;
  bool _scanning = false;
  List<dynamic> _stationData = [];
  bool _create = true;
  String title = '새 프로젝트';
  int _currentIndex = 0;
  bool _isConnect = false;
  FlutterNsd? flutterNsd;
  Map<String, dynamic> _userMap = {'project': []};
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _connectIpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString('user');
    if (userPref != null) {
      setState(() {
        _userMap = jsonDecode(userPref) as Map<String, dynamic>;
      });
    }
  }

  void _findStation(Map<String, dynamic> project) {
    _stationName = project['stationName'];
    _connectIp = project['connectIp'];
    _stationData = project['stationData'];
    _stationNameController.text = _stationName;
    _connectIpController.text = _connectIp;
    _currentIndex = _userMap['project'].indexOf(project);
    setState(() {});
  }

  void _deleteStation(dynamic station) async {
    var stationIndex = _userMap['project'].indexOf(station);
    _userMap['project'].removeAt(stationIndex);
    setState(() {});
  }

  void _saveStation() async {
    if (_stationName == '') {
      Toast.show('Enter a project name.', duration: Toast.lengthShort, gravity:  Toast.bottom);
      return;
    }

    if (_isConnect == false) {
      Toast.show('Please check the connection.', duration: Toast.lengthShort, gravity:  Toast.bottom);
      return;
    }

    Map<String, dynamic> stationInfo = {
      'stationName': _stationName,
      'connectIp': _connectIp,
      'activate': true,
      'stationData': _stationData,
      'isCamera': _isCamera,
      'isRemote': _isRemote
    };

    if (_create) {
      for (var station in _userMap['project']) {
        if (_stationName == station['stationName']) {
          Toast.show('This is a project name that already exists.', duration: Toast.lengthShort, gravity:  Toast.bottom);
          return;
        }
      }

      setState(() {
        _userMap['project'].add(stationInfo);
      });
    } else {
      setState(() {
        _userMap['project'][_currentIndex] = stationInfo;
      });
    }

    Navigator.of(context).pop();
  }

  void _saveProject() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_userMap));
    Toast.show("has been saved.", duration: Toast.lengthShort, gravity:  Toast.bottom);
  }

  void initNsd() async {
    flutterNsd = FlutterNsd();
    flutterNsd!.stream.listen((nsdServiceInfo) {
      print('Discovered service name: ${nsdServiceInfo.name}');
      print('Discovered service hostname/IP: ${nsdServiceInfo.hostname}');
      print('Discovered service port: ${nsdServiceInfo.port}');
    }, onError: (e) {
      if (e is NsdError) {
        print(NsdError);
      }
    });
  }

  @override
  void initState() {
    _getUser();
    initNsd();
    super.initState();
  }


  Future _searchNet() async {
    await flutterNsd!.discoverServices('_http._tcp');
  }

  void _connectStation(StateSetter _setState) async {
    var url = (_connectIp.contains(':')) ? 'http://' + _connectIp + '/setting?password=' + _password : 'http://seojun.ddns.net/setting?password=' + _password + '&id=' + _connectIp;

    var res =
        await http.read(Uri.parse(url));
    var parsed = json.decode(res);
    if (parsed['success']) {
      _setState(() {
        _stationData = parsed['data'];
        _isCamera = parsed['camera'];
        _isRemote = parsed['remote'];
        _isConnect = true;
      });
      Toast.show("Connection confirmed.", duration: Toast.lengthShort, gravity:  Toast.bottom);
    } else {
      Toast.show("Please confirm your password.", duration: Toast.lengthShort, gravity:  Toast.bottom);
    }
  }

  void _showFullDialog() {
    setState(() {
      _stationName = '';
      _connectIp = '';
      _stationData = [];
      _password = '';
    });
    _stationNameController.text = '';
    _connectIpController.text = '';
    _passwordController.text = '';

    Navigator.of(context)
        .push(MaterialPageRoute<String>(builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Scaffold(
            appBar: AppBar(
                title: Text(''),
                elevation: 0.0,
                backgroundColor: Colors.white,
                leading: GestureDetector(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  TextButton(
                      onPressed: _saveStation,
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
                    Row(children: <Widget>[
                      CustomLabel(text: 'Project Name'),
                      Spacer(),
                      Expanded(
                          flex: 2,
                          child: CustomFormField(
                              controller: _stationNameController,
                              onChange: (value) {
                                setState(() {
                                  _stationName = value;
                                });
                              },
                              onPressed: () {
                                setState(() {
                                  _stationName = '';
                                });
                              })),
                    ]),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        CustomLabel(text: 'IP'),
                        Spacer(),
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
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _searchNet,
                            child: const Icon(
                              Icons.search_sharp,
                              size: 20
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)
                              )
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        CustomLabel(text: 'Password'),
                        Spacer(),
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
                            _connectStation(setState);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: primaryBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Connect check',
                            style: TextStyle(fontSize: 16),
                          )),
                    ),
                    /*const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.maxFinite,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: _stationData.map((v) {
                          var name = v['name'] as String;
                          var value = v['value'] as bool;
                          return Row(
                            children: [
                              Text(name),
                              Spacer(),
                              Checkbox(
                                  value: value,
                                  onChanged: (bool? state) {
                                    setState(() {
                                      v['value'] = state!;
                                    });
                                  }),
                            ],
                          );
                        }).toList(),
                      ),
                    )*/
                  ],
                ),
              ),
            ));
      });
    }));
  }

  @override
  void dispose() {
    _stationNameController.dispose();
    _connectIpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: _getUser,
                child: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(90, 40), primary: primaryBlue),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: _saveProject,
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(90, 40), primary: primaryBlue)),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _create = true;
                      _isConnect = false;
                    });
                    _showFullDialog();
                  },
                  child: const Text('New'),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(90, 40), primary: primaryBlue)),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: _userMap['project'].map<Widget>((pj) {
              String stationName = pj['stationName'];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Checkbox(
                        value: pj['activate'],
                        onChanged: (value) {
                          setState(() {
                            pj['activate'] = value;
                          });
                        }),
                    SizedBox(
                      width: 20,
                    ),
                    Text(stationName),
                    Spacer(),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _create = false;
                          });
                          _showFullDialog();
                          _findStation(pj);
                        },
                        icon: Icon(Icons.edit)),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                        onPressed: () {
                          _deleteStation(pj);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[500],
                        ))
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
