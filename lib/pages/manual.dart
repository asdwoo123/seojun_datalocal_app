import 'package:flutter/material.dart';
import 'package:seojun_datalocal_app/pages/helpOne.dart';
import 'package:seojun_datalocal_app/pages/helpTwo.dart';
import 'package:seojun_datalocal_app/theme.dart';

class ManualPage extends StatefulWidget {
  const ManualPage({Key? key}) : super(key: key);

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
        backgroundColor: primaryBlue,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: backgroundGrey),
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const HelpOnePage()));
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.white,),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      Text("About each page"),
                      Spacer(),
                      Icon(Icons.arrow_forward)
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const HelpTwoPage()));
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      Text("Application initial setup"),
                      Spacer(),
                      Icon(Icons.arrow_forward)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


