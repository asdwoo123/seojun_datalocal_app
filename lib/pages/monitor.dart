import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:seojun_datalocal_app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';

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

  void _handleTouchStart(
      LongPressStartDetails details, String connectIp, GlobalKey? key) {
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
    _postJsonHttp('http://' + connectIp + '/pantilt', {'action': action});
  }

  void _handleTouchEnd(LongPressEndDetails details, String connectIp) {
    _postJsonHttp('http://' + connectIp + '/pantilt', {'action': 'stop'});
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
        IO.Socket socket = IO.io(
            'http://' + station.connectIp,
            IO.OptionBuilder()
                .setTransports(['websocket'])
                .enableReconnection()
                .build());

        _sockets.add(socket);

        Map<String, dynamic> value = {};

        if (socket.connected) {
          setState(() {
            station.isConnect = true;
          });
        }

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
            .forEach((stationData) async {
          if (stationData.type == 'int') {
            value[stationData.name] = '0';
          }

          if (stationData.type == 'float') {
            value[stationData.name] = '0.0';
          }

          if (stationData.type == 'string') {
            value[stationData.name] = 'Nan';
          }

          if (stationData.type == 'bool') {
            value[stationData.name] = 'true';
          }

          var res = await http.read(Uri.parse(
              'http://' + station.connectIp + '/nodeId/' + stationData.nodeId));
          var parsed = json.decode(res);
          setState(() {
            station.data[stationData.name] = parsed['value'].toString();
          });

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

  void _postJsonHttp(String connectUrl, Map<String, dynamic> data) {
    http.post(Uri.parse(connectUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data));
  }

  void _showRemoteSheet(String connectIp) {
    showAdaptiveActionSheet(context: context,
        title: const Text('remote'),
        actions:
    <BottomSheetAction>[
      BottomSheetAction(title: Text('Start'), onPressed: () {
        _postJsonHttp('http://' + connectIp + '/remote', {'action': 'start'});
        Navigator.pop(context);
      }),
      BottomSheetAction(title: Text('Reset'), onPressed: () {
        _postJsonHttp('http://' + connectIp + '/remote', {'action': 'reset'});
        Navigator.pop(context);
      }),
      BottomSheetAction(title: Text('Stop'), onPressed: () {
        _postJsonHttp('http://' + connectIp + '/remote', {'action': 'stop'});
        Navigator.pop(context);
      }),
    ]);
  }

  void _showShareSheet(Station station) {
    showAdaptiveActionSheet(context: context, title: const Text('share'),
    actions: <BottomSheetAction>[
      BottomSheetAction(title: Text('Kakao talk'), onPressed: () {
        _shareKaKao(station);
      })
    ]);
  }

  void _shareKaKao(Station station) async {
    final FeedTemplate defaultFeed = FeedTemplate(content: Content(
      title: station.stationName,
      imageUrl: Uri.parse(
          'http://' + station.connectIp + '/?action=capture'
      ),
      link: Link(
        webUrl: Uri.parse(''),
        mobileWebUrl: Uri.parse('')
      )
    ),
      itemContent: ItemContent(
        items: station.stationInfo
            .where((e) => e.activate)
            .map<ItemInfo>((stationData) {
              return ItemInfo(item: stationData.name, itemOp: station.data[stationData.name]);
        }).toList()
    ));

    Uri shareUrl = await WebSharerClient.instance.defaultTemplateUri(template: defaultFeed);
    await launchBrowserTab(shareUrl);
  }


  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  void dispose() {
    /*_sockets.forEach((socket) => socket.disconnect());*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: _projects.map<Widget>((station) {
          return Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        station.stationName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      ElevatedButton(onPressed: () {
                        _showShareSheet(station);
                      }, child: Center(child: Text('Share'),), style: ElevatedButton.styleFrom(
                          primary: textGrey),
                      ),
                      SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: () {
                          _showRemoteSheet(station.connectIp);
                        },
                        child: Center(
                          child: Text('Remote'),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: primaryBlue),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                      onLongPressStart: (LongPressStartDetails details) {
                        _handleTouchStart(details, station.connectIp,
                            _globalKeys[station.stationName]);
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
                      Text((station.isConnect) ? '연결' : '연결되지않음',
                        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),)
                    ],
                  ),
                  ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: station.stationInfo
                        .where((e) => e.activate)
                        .map<Widget>((stationData) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 3.0),
                        child: Row(
                          children: [
                            Text(
                              stationData.name,
                              style: TextStyle(fontSize: 15.0),
                            ),
                            Spacer(),
                            Text(
                              station.data[stationData.name],
                              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
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
