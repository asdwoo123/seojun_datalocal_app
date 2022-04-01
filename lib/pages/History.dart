import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:seojun_datalocal_app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Station.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future myFuture;
  List<Station> _projects = [];
  int _stationIndex = 0;
  int _page = 0;
  bool _pageEnd = false;
  String _barcode = '';
  bool _isLoading = false;
  List<DataRow> _rows = [];
  List<DataColumn> _columns = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _barcodeController = TextEditingController();
  DateTimeRange _dateTimeRange = DateTimeRange(start: DateTime.now().subtract(Duration(days: 2)), end: DateTime.now());


  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString('user');
    if (userPref != null) {
      var userInfo = jsonDecode(userPref);
      List<Station> projects = [];
      userInfo['project'].forEach((project) {
        if (!project['activate']) return;
        var station = Station.fromJson(project);
        projects.add(station);
      });
      setState(() {
        _projects = projects;
      });
    }
  }

  Future<Map<String, dynamic>> _getData() async {
    if (_projects.isNotEmpty) {
      var station = _projects[_stationIndex];
      var start_period = _dateTimeRange.start;
      var end_period = _dateTimeRange.end;
      var res = await http
          .read(Uri.parse('http://' + station.connectIp + '/data?page=' + _page.toString() + '&barcode=' + _barcode
      + '&start_period=' + start_period.toIso8601String() + '&end_period=' + end_period.toIso8601String() ));
      if (res == '[]') {
        setState(() {
          _pageEnd = true;
          _isLoading = false;
        });
        if (_page == 0) {
          throw Exception('no data');
        }
        if (_columns.isNotEmpty) {
          return {'columns': _columns, 'rows': _rows};
        } else {
          throw Exception('not load data');
        }
      }


      var columns = jsonDecode(res)[0]
          .keys
          .toList()
          .map<DataColumn>((String column) => DataColumn(label: Text(column)))
          .toList();

      var rows = jsonDecode(res)
      .map((v) {
        v['time'] = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.parse(v['time']));
        return v;
      })
          .map((value) => value.values.map<DataCell>((v) {
        var value;
        value = v ?? 0;
        return DataCell(Text(value.toString()));
      }).toList())
          .map<DataRow>((r) => DataRow(cells: r))
          .toList();

      if (_page > 0) {
        setState(() {
          _rows.addAll(rows);
        });
      } else {
        setState(() {
          _rows = rows;
        });
      }

      setState(() {
        _columns = columns;
        _isLoading = false;
      });
      return {'columns': columns, 'rows': _rows};
    } else {
      throw Exception('not load prefs');
    }
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(context: context,
        initialDateRange: _dateTimeRange,
        firstDate: DateTime(DateTime.now().year - 5), lastDate: DateTime(DateTime.now().year + 1));

    setState(() {
      _dateTimeRange = newDateRange ?? _dateTimeRange;
    });
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if(_scrollController.position.pixels  == _scrollController.position.maxScrollExtent && !_isLoading){
        if (!_pageEnd){
          setState(() {
            _isLoading = true;
            _page = _page + 1;
            myFuture = _getData();
          });
        }
      }
    });
    _getUser();
    myFuture = _getData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = _dateTimeRange.start;
    final end = _dateTimeRange.end;

    if (_projects.isNotEmpty) {
    return ListView(
      controller: _scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 12.0, 0, 12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: DropdownButton(value: _projects[_stationIndex].stationName, items: _projects.map((station) {
                          return DropdownMenuItem(value: station.stationName, child: Text(station.stationName));
                        }).toList(), onChanged: (Object? value) {
                          var index = _projects.indexOf(_projects.where((station) => station.stationName == value).toList()[0]);
                          setState(() {
                            _stationIndex = index;
                          });
                        }, underline: SizedBox(),),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                           borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none
                          )
                        ),
                        contentPadding: const EdgeInsets.all(12.0),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search barcode',
                        suffixIcon: _barcodeController.text.isEmpty ? null : IconButton(
                          onPressed: () {
                            _barcodeController.clear();
                            setState(() {
                              _barcode = '';
                            });
                          },
                          icon: Icon(Icons.clear)
                        )
                      ),
                      controller: _barcodeController,
                      onChanged: (value) {
                        setState(() {
                          _barcode = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(onPressed: () {
                      setState(() {
                        _page = 0;
                        _pageEnd = false;
                        myFuture = _getData();
                      });
                    }, child: Icon(Icons.search_sharp, size: 20,),
                      style: ElevatedButton.styleFrom(
                        primary: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),),
                  ),
                  SizedBox(width: 15,)
                ],
              ),
            ],
          ),
        ),
        FutureBuilder(
            future: myFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return Container();
              } else {
                return Container(
                  margin: EdgeInsets.fromLTRB(15, 10, 0, 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                            columns: snapshot.data['columns'],
                            rows: snapshot.data['rows'])),
                  ),
                );
              }
            }),
        (_isLoading) ? Container(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation(Colors.blue[100]),
                backgroundColor: Colors.blue[600],
              ),
            ),
          ) : Container()
      ],
    );
  } else {
      return Container();
    }
    }
}
