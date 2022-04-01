import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:seojun_datalocal_app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  String _stationName = '';
  String _connectIp = '';
  List<dynamic> _stationData = [];
  bool _create = true;
  String title = '새 프로젝트';
  int _currentIndex = 0;
  Map<String, dynamic> _userMap = {'project': []};
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _connectIpController = TextEditingController();

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
    setState(() {
      _stationName = project['stationName'];
      _connectIp = project['connectIp'];
      _stationData = project['stationData'];
    });

    _stationNameController.text = _stationName;
    _connectIpController.text = _connectIp;

    _currentIndex = _userMap['project'].indexOf(project);
  }

  void _deleteStation(dynamic station) async {
    var stationIndex = _userMap['project'].indexOf(station);
    setState(() {
      _userMap['project'].removeAt(stationIndex);
    });
  }

  void _saveStation() async {
    if (_stationName == '') {
      Fluttertoast.showToast(
        msg: '이름을 입력해주세요.',
      );
      return;
    }

    Map<String, dynamic> stationInfo = {
      'stationName': _stationName,
      'connectIp': _connectIp,
      'activate': true,
      'stationData': _stationData
    };

    if (_create) {
      for (var station in _userMap['project']) {
        if (_stationName == station['stationName']) {
          Fluttertoast.showToast(
            msg: '이미 존재하는 이름입니다.',
          );
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
    Fluttertoast.showToast(
      msg: '저장되었습니다.',
    );
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  void _connectStation(StateSetter _setState) async {
    var res = await http.read(Uri.parse('http://' + _connectIp + '/setting'));
    var parsed = json.decode(res);

    _setState(() {
      _stationData = parsed['data'];
    });
  }

  void _showFullDialog() {
    setState(() {
      _stationName = '';
      _connectIp = '';
      _stationData = [];
    });

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
                  TextButton(onPressed: _saveStation, child: const Text('저장하기', style: TextStyle(color: Colors.black),))
                ]),
            body: Container(
              padding: EdgeInsets.all(20.0),
              color: const Color(0xfff2f2f2),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: ListBody(
                  children: [
                    const Text('이름', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none
                              )
                          ),
                          hintText: 'Enter the station name',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12.0),
                          suffixIcon: _stationNameController.text.isEmpty ? null : IconButton(
                              onPressed: () {
                                _stationNameController.clear();
                                setState(() {
                                  _stationName = '';
                                });
                              }, icon: Icon(Icons.clear)
                          )
                      ),
                      controller: _stationNameController,
                      onChanged: (value) {
                        setState(() {
                          _stationName = value;
                        });
                      },
                    ),
                    SizedBox(height: 20,),
                    const Text('아이피', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none
                              )
                          ),
                          hintText: 'Connect ip',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12.0),
                          suffixIcon: _connectIpController.text.isEmpty ? null : IconButton(
                              onPressed: () {
                                _connectIpController.clear();
                                setState(() {
                                  _connectIp = '';
                                });
                              }, icon: Icon(Icons.clear)
                          )
                      ),
                      controller: _connectIpController,
                      onChanged: (value) {
                        setState(() {
                          _connectIp = value;
                        });
                      },
                    ),
                    SizedBox(height: 30,),
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
                              borderRadius: BorderRadius.circular(12)
                            ),
                          ),
                          child: Text('연결', style: TextStyle(fontSize: 16),)),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: _stationData.map((v) {
                        var name = v['name'] as String;
                        var value = v['value'] as bool;
                        return Row(
                          children: [
                            Text(name, style: TextStyle(fontSize: 16)),
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
                  ],
                ),
              ),
            ),
          );
        }
      );
    }));
  }

  /*void _showDialog() {
    setState(() {
      _stationName = '';
      _connectIp = '';
      _stationData = [];
    });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text('이름'),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none
                            )
                          ),
                            hintText: 'Enter the station name',
                            filled: true,
                            fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12.0),
                          suffixIcon: IconButton(
                              onPressed: () {}, icon: Icon(Icons.clear)
                          )
                        ),
                        initialValue: _stationName,
                        controller: _stationNameController,
                        onChanged: (value) {
                          setState(() {
                            _stationName = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('연결 아이피'),
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Enter the connect ip'),
                                onChanged: (value) {
                                  _connectIp = value;
                                },
                                initialValue: _connectIp,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              flex: 1,
                              child: ElevatedButton(
                                  onPressed: () {
                                    _connectStation(setState);
                                  },
                                  child: Icon(Icons.cast_connected)))
                        ],
                      ),
                      const SizedBox(
                        height: 16,
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
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '취소',
                                style: TextStyle(fontSize: 15),
                              )),
                          TextButton(
                              onPressed: _saveStation,
                              child: Text(
                                '저장',
                                style: TextStyle(fontSize: 15),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }*/

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
                child: const Text('초기화'),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(90, 40), primary: primaryBlue),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: _saveProject,
                  child: const Text('저장'),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(90, 40), primary: primaryBlue)),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _create = true;
                    });
                    _showFullDialog();
                  },
                  child: const Text('설비 등록'),
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
