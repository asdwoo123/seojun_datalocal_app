import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../model/Station.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({Key? key}) : super(key: key);

  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  List<Station> _projects = [];
  List<IO.Socket> _sockets = [];

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString('user');
    if (userPref != null) {
      var userInfo = jsonDecode(userPref);
      List<Station> projects = [];
      userInfo['project'].forEach((project) {
        var station = Station.fromJson(project);

        IO.Socket socket = IO.io('http://' + station.connectIp, <String, dynamic>{
          'transports': ['websocket']
        });
        _sockets.add(socket);

        Map<String, dynamic> value = {};
        station.stationInfo.forEach((stationData) {
          if (stationData.type == 'int') {
            value[stationData.name] = '0';
          }
          if (stationData.type == 'float') {
            value[stationData.name] = '0.0';
          }
          if (stationData.type == 'string') {
            value[stationData.name] = '';
          }
          if (stationData.type == 'bool') {
            value[stationData.name] = 'true';
          }

          socket.on(stationData.name, (v) {
            print(stationData.name);
          });
        });
        station.data = value;
        projects.add(station);
      });
      setState(() {
        _projects = projects;
      });
    }
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  void dispose() {
    _sockets.forEach((s) { s.disconnect(); });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ListView(
        children: _projects.map<Widget>((station) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(station.stationName),
                  const SizedBox(height: 20,),
                  ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: station.stationInfo.map<Widget>((stationData) {
                      return Row(children: [
                        Text(stationData.name),
                        Spacer(),
                        Text(station.data[stationData.name])
                      ],);
                    }).toList(),)
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
