import 'package:flutter/material.dart';
import 'package:seojun_datalocal_app/pages/History.dart';
import 'package:seojun_datalocal_app/pages/monitor.dart';
import 'package:seojun_datalocal_app/pages/project.dart';
import 'package:seojun_datalocal_app/pages/setting.dart';
import 'package:seojun_datalocal_app/theme.dart';

List<Widget> widgetOptions = [
  MonitorPage(),
  HistoryPage(),
  ProjectPage(),
  SettingPage()
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const double _size = 30;

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
          decoration: BoxDecoration(color: backgroundGrey),
          child: widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar:
      Container(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: primaryBlue,
          elevation: 0.0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.desktop_windows_sharp, size: _size), label: '모니터링'),
            BottomNavigationBarItem(icon: Icon(Icons.history, size: _size), label: '기록'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment, size: _size), label: '프로젝트관리'),
            BottomNavigationBarItem(icon: Icon(Icons.settings, size: _size), label: '설정'),
          ],
          currentIndex: _selectedIndex,
          /*selectedItemColor: Colors.amber[800],*/
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
