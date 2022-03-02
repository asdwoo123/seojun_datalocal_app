import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    var connectIp = _projects[_stationIndex];
    var nodeId = _projects[_stationIndex].stationInfo[_dataIndex].nodeId;
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButton(value: _projects[0].stationName, items: _projects.map((station) {
              return DropdownMenuItem(value: station.stationName, child: Text(station.stationName));
            }).toList(), onChanged: (Object? value) { 
              print(value);
            },),
            SizedBox(height: 17,),
            DropdownButton(value: _projects[0].stationInfo[0].name, items: _projects[0].stationInfo.map((data) {
              return DropdownMenuItem(value: data.name, child: Text(data.name));
            }).toList(), onChanged: (Object? value) {
              print(value);
            },),
            SizedBox(height: 17,),
            TextFormField(),
            ElevatedButton(onPressed: () {}, child: const Center(child: Text('remote')))
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
