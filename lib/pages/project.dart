import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  String _projectName = '';
  String _connectIp = '';

  _showDialog() {
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
                      Container(
                        decoration: BoxDecoration(),
                        child: TextFormField(
                          decoration:
                              InputDecoration(hintText: 'Enter the connect ip'),
                        ),
                      ),
                      ElevatedButton(onPressed: () {}, child: Center(child: Text('연결'),))
                    ],
                  ),
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
