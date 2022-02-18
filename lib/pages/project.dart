import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  String _projectName = '';
  String _connectIp = '';
  List<Map<String, dynamic>> _stationData = [];

  void _connectStation() async {
    var res = await http.read(Uri.parse('http://192.168.0.48:3000/setting'));
    var parsed = json.decode(res);
    this.setState(() {
      _stationData = parsed['data'];
    });
  }

  Widget _showWid() {
    if (_stationData.length > 0)
    {
      return Container(
        width: double.maxFinite,
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: _stationData.map((v) {
            var name = v['name'] as String;
            return TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: name),
            );
          }).toList(),
        ),
      );
    }
    else
    {
      return Container();
    }
  }

  void _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('새 프로젝트'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('이름'),
                  Container(
                    decoration: BoxDecoration(),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter the station name',
                        /*border: const OutlineInputBorder(
                      borderSide: BorderSide.none
                    )*/
                      ),
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
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                          flex: 1,
                          child: ElevatedButton(
                              onPressed: _connectStation,
                              child: Center(
                                child: Text('연결'),
                              )))
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _showWid()
                ],
              ),
            ),
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
              TextButton(onPressed: () {}, child: const Text('저장')),
              TextButton(onPressed: _showDialog, child: const Text('설비 등록')),
            ],
          ),
        ],
      ),
    );
  }
}
