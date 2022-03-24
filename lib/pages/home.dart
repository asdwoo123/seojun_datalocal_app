import 'package:flutter/material.dart';
import 'package:seojun_datalocal_app/pages/History.dart';
import 'package:seojun_datalocal_app/pages/kakao.dart';
import 'package:seojun_datalocal_app/pages/monitor.dart';
import 'package:seojun_datalocal_app/pages/project.dart';

List<Widget> widgetOptions = [
  MonitorPage(),
  HistoryPage(),
  ProjectPage()
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar:
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30),
          ),
          /*boxShadow: [
            BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
          ],*/
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.desktop_windows), label: '모니터링'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: '기록'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '프로젝트관리'),
          ],
          currentIndex: _selectedIndex,
          /*selectedItemColor: Colors.amber[800],*/
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
