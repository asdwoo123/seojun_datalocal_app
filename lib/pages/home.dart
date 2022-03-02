import 'package:flutter/material.dart';
import 'package:seojun_datalocal_app/pages/monitor.dart';
import 'package:seojun_datalocal_app/pages/project.dart';
import 'package:seojun_datalocal_app/pages/remote.dart';
import 'package:seojun_datalocal_app/pages/setting.dart';

List<Widget> widgetOptions = [
  MonitorPage(),
  RemotePage(),
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
      body: SafeArea(
        child: Container(
          child: widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.desktop_windows), label: 'Monitor'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_remote), label: 'Remote'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Project'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
