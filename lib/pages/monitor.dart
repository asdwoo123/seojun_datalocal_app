import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';
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

  _getSize(GlobalKey key) {
    if (key.currentContext != null) {
      final RenderBox renderBox =
      key.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    }
  }

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
    _postJsonHttp('https://' + connectIp + '.loca.lt/pantilt', {'action': action});
  }

  void _handleTouchEnd(LongPressEndDetails details, String connectIp) {
    _postJsonHttp('https://' + connectIp + '.loca.lt/pantilt', {'action': 'stop'});
  }

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString('user');
    if (userPref != null) {
      var userInfo = jsonDecode(userPref);
      List<Station> projects = [];
      userInfo['project'].forEach((project) {
        if (!project['activate']) return;
        bool isProxy = project['connectIp'].contains(":");
        var station = Station.fromJson(project);
        _globalKeys[station.stationName] = GlobalKey();
        var url = (isProxy) ? 'http://' + station.connectIp : 'https://' + station.connectIp + '.loca.lt';
        IO.Socket socket = IO.io(
            url,
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
          value[stationData.name] = '';

          bool isProxy = station.connectIp.contains(":");
          var url = (isProxy) ? 'http://' + station.connectIp : 'https://' + station.connectIp + '.loca.lt';
          var res = await http.read(Uri.parse(
              url + '/nodeId/' + stationData.nodeId));
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
    bool isProxy = connectIp.contains(":");
    var url = (isProxy) ? 'http://' + connectIp : 'https://' + connectIp + '.loca.lt';
    return url + '?action=stream';
  }

  void _postJsonHttp(String connectUrl, Map<String, dynamic> data) async {
    http.Response response = await http.post(Uri.parse(connectUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data));
    Fluttertoast.showToast(msg: jsonDecode(response.body)['message']);
  }

  void _showRemoteSheet(String connectIp) {
    showAdaptiveActionSheet(context: context,
        title: const Text('remote'),
        actions:
    <BottomSheetAction>[
      BottomSheetAction(title: Text('Start'), onPressed: () {
        _postJsonHttp('https://' + connectIp + '.loca.lt/remote', {'action': 'start'});
        Navigator.pop(context);
      }),
      BottomSheetAction(title: Text('Reset'), onPressed: () {
        _postJsonHttp('https://' + connectIp + '.loca.lt/remote', {'action': 'reset'});
        Navigator.pop(context);
      }),
      BottomSheetAction(title: Text('Stop'), onPressed: () {
        _postJsonHttp('https://' + connectIp + '.loca.lt/remote', {'action': 'stop'});
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
    String imgUrl = '';
    try {
      if (station.isCamera) {
        var rng = new Random();
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        File file = new File('$tempPath' + (rng.nextInt(100).toString() + '.jpg'));
        http.Response response = await http.get(Uri.parse('https://' + station.connectIp + '.loca.lt/?action=capture'));
        await file.writeAsBytes(response.bodyBytes);
        ImageUploadResult imageUploadResult = await LinkClient.instance.uploadImage(image: file);
        imgUrl = imageUploadResult.infos.original.url;
      }

      FeedTemplate defaultFeed = FeedTemplate(content: Content(
          title: station.stationName,
          imageUrl: Uri.parse(
              imgUrl
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

      var isKaKao = await LinkClient.instance.isKakaoLinkAvailable();
      if (isKaKao) {
        Uri shareUrl = await LinkClient.instance.defaultTemplate(template: defaultFeed);
        await LinkClient.instance.launchKakaoTalk(shareUrl);
      } else {
        Uri shareUrl = await WebSharerClient.instance.defaultTemplateUri(template: defaultFeed);
        await launchBrowserTab(shareUrl);
      }
    } catch (e) {
      print('이미지 업로드 실패 $e');
    }
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
            margin: EdgeInsets.only(bottom: 20),
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 10,
                        child: Container(
                          child: Text(
                            station.stationName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          _showShareSheet(station);
                        },
                        child: Text('Share'),
                        style: OutlinedButton.styleFrom(
                            primary: primaryBlue,
                            fixedSize: Size(90, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                                color: primaryBlue
                            )
                        ),
                      ),
                      SizedBox(width: 10,),
                      (station.isRemote) ? ElevatedButton(onPressed: () {
                        _showRemoteSheet(station.connectIp);
                      }, child: Text('Remote'), style: ElevatedButton.styleFrom(
                        primary: primaryBlue,
                        fixedSize: Size(90, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      ) : Container(),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  (station.isCamera) ? GestureDetector(
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
                      )) : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text('상태'),
                      Spacer(),
                      Text((station.isConnect) ? 'Connect' : 'Disconnect',
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
