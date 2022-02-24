import 'dart:convert';

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
  String _connectIp = '192.168.0.48:3000';
  List<dynamic> _stationData = [];
  bool _create = true;
  String title = '새 프로젝트';
  Map<String, dynamic> _userMap = {'project': []};

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString('user');
    if (userPref != null) {
      setState(() {
        _userMap = jsonDecode(userPref) as Map<String, dynamic>;
      });
    }
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
    if (_create) {
      for (var station in _userMap['project']) {
        if (_stationName == station['stationName']) {
          Fluttertoast.showToast(
            msg: '이미 존재하는 이름입니다.',
          );
          return;
        }
      }
    }

    Map<String, dynamic> stationInfo = {
      'stationName': _stationName,
      'connectIp': _connectIp,
      'stationData': _stationData
    };
    setState(() {
      _userMap['project'].add(stationInfo);
    });
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

  void _showDialog() {
    setState(() {
      _stationData = [];
    });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(title),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('이름'),
                      Container(
                        decoration: BoxDecoration(),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter the station name',
                            /*border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1, color: textWhiteGrey)
                            )*/
                          ),
                          onChanged: (value) {
                            _stationName = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('연결 아이피'),
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
                                  child: Center(
                                    child: Text('연결'),
                                  )))
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
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: _saveStation, child: Text('저장')),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('취소')),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              TextButton(onPressed: _saveProject, child: const Text('저장')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _create = true;
                    });
                    _showDialog();
                  },
                  child: const Text('설비 등록')),
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
              return Row(
                children: [
                  Checkbox(value: true, onChanged: (value) {}),
                  SizedBox(
                    width: 20,
                  ),
                  Text(stationName),
                  Spacer(),
                  ElevatedButton(onPressed: () { _deleteStation(pj); }, child: Center(child: Text('del'),))
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
