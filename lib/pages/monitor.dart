import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

import '../model/Station.dart';


class MonitorPage extends StatefulWidget {
  const MonitorPage({Key? key}) : super(key: key);

  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  List<Station> _projects = [];
  List<IO.Socket> _sockets = [];
  Map<String, GlobalKey> _globalKeys = {};

  void _handleTouchStart(LongPressStartDetails details, String connectIp, GlobalKey? key) {
    if (key == null) return;
    var size = _getSize(key);
    var width = size.width;
    var height = size.height;
    var x = details.localPosition.dx;
    var y = details.localPosition.dy;

    var action = '';

    if (x < 90) {
      action = 'left';
    } else if (x > width - 90) {
      action = 'right';
    } else if (y < height / 2) {
      action = 'top';
    } else {
      action = 'bottom';
    }

    http.post(Uri.parse('http://' + connectIp + '/pantilt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}));
  }

  void _handleTouchEnd(LongPressEndDetails details, String connectIp) {
    http.post(Uri.parse('http://' + connectIp + '/pantilt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'stop'}));
  }

  _getSize(GlobalKey key) {
    if (key.currentContext != null) {
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    }
  }

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString('user');
    if (userPref != null) {
      var userInfo = jsonDecode(userPref);
      List<Station> projects = [];
      userInfo['project'].forEach((project) {
        if (!project['activate']) return;
        var station = Station.fromJson(project);
        _globalKeys[station.stationName] = GlobalKey();
        IO.Socket socket =
            IO.io('http://' + station.connectIp, IO.OptionBuilder().setTransports(['websocket'])
                .build()
            );
        _sockets.add(socket);
        Map<String, dynamic> value = {};
        socket.onConnect((data) {
          if (mounted == true) {
            setState(() {
              station.isConnect = true;
            });
          }
        });
        socket.onDisconnect((data) {
          if (mounted == true) {

            setState(() {
              station.isConnect = false;
            });
          }
        });
        station.stationInfo
            .where((stationData) => stationData.activate)
            .forEach((stationData) {
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
            if (mounted == true) {
              setState(() {
                station.data[stationData.name] = v['data'].toString();
              });
            }
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

  String _cameraUrl(String connectIp) {
    return 'http://' + connectIp + '?action=stream';
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  void dispose() {
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
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onLongPressStart: (LongPressStartDetails details) {
                        _handleTouchStart(details, station.connectIp, _globalKeys[station.stationName]);
                      },
                      onLongPressEnd: (LongPressEndDetails details) {
                        _handleTouchEnd(details, station.connectIp);
                      },
                      key: _globalKeys[station.stationName],
                      child: Mjpeg(
                        isLive: true,
                        stream: _cameraUrl(station.connectIp),
                        error: (context, error, stack) {
                          return Container();
                        },
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text('상태'),
                      Spacer(),
                      Text((station.isConnect) ? '연결' : '연결되지않음')
                    ],
                  ),
                  ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: station.stationInfo
                        .where((e) => e.activate)
                        .map<Widget>((stationData) {
                      return Row(
                        children: [
                          Text(stationData.name),
                          Spacer(),
                          Text(station.data[stationData.name])
                        ],
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
