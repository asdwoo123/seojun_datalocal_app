import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/Station.dart';

class RemotePage extends StatefulWidget {
  const RemotePage({Key? key}) : super(key: key);

  @override
  _RemotePageState createState() => _RemotePageState();
}

class _RemotePageState extends State<RemotePage> {
  List<Station> _projects = [];
  int _stationIndex = 0;
  int _dataIndex = 0;
  String _remoteValue = '';

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString('user');
    if (userPref != null) {
      var userInfo = jsonDecode(userPref);
      List<Station> projects = [];
      userInfo['project'].forEach((project) {
        if (!project['activate']) return;
        var station = Station.fromJson(project);
        projects.add(station);
      });
      setState(() {
        _projects = projects;
      });
    }
  }

  void _remoteStation() async {
    var connectIp = _projects[_stationIndex].connectIp;
    var nodeId = _projects[_stationIndex].stationInfo[_dataIndex].nodeId;
    var remoteValue = int.parse(_remoteValue);

    http.post(Uri.parse('http://' + connectIp + '/remote'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'nodeId': nodeId, 'value': remoteValue}));
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_projects.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            DropdownButton(value: _projects[_stationIndex].stationName, items: _projects.map((station) {
              return DropdownMenuItem(value: station.stationName, child: Text(station.stationName));
            }).toList(), onChanged: (Object? value) { 
              var index = _projects.indexOf(_projects.where((station) => station.stationName == value).toList()[0]);
              setState(() {
                _stationIndex = index;
              });
            },),
            SizedBox(height: 17,),
            DropdownButton(value: _projects[_stationIndex].stationInfo[_dataIndex].name, items: _projects[_stationIndex].stationInfo.map((data) {
              return DropdownMenuItem(value: data.name, child: Text(data.name));
            }).toList(), onChanged: (Object? value) {
              var stationInfo = _projects[_stationIndex].stationInfo;
              var index = stationInfo.indexOf(stationInfo.where((data) => data.name == value).toList()[0]);
              setState(() {
                _dataIndex = index;
              });
            },),
            SizedBox(height: 17,),
            TextFormField(keyboardType: TextInputType.number, onChanged: (value) => setState(() {
              _remoteValue = value;
            }),),
            SizedBox(height: 25,),
            ElevatedButton(onPressed: _remoteStation, child: const Center(child: Text('remote')))
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
