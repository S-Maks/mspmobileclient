import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatelessWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Dashboard'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([fetchAgents(), fetchInstalledPatches()]),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: new Text(
                  'Building dashboard, please await...',
                  style: style,
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                final agents = snapshot.data[0] as Page;
                final patches = snapshot.data[1] as int;

                return Container(
                  margin: EdgeInsets.all(20),
                  child: Column(children: [
                    createSummaryWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    createItManagementScopeWidget(agents),
                    SizedBox(
                      height: 20,
                    ),
                    createItManagementResultsWidget(patches),
                  ]),
                );
              }
          }
        },
      ),
    );
  }
}

const style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

Widget createSummaryWidget() {
  return Column(
    children: [
      Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Text(
          'MSP Invoice Dashboard',
          style: style.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      ColoredBox(
        color: Color.fromARGB(255, 219, 229, 241),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                  softWrap: true,
                  style: style,
                ),
              ),
            ),
            Expanded(
                flex: 5,
                child: Table(
                  children: [
                    TableRow(children: [
                      TableCell(
                          child: Text(
                        'Invoice #',
                        style: style,
                      )),
                      TableCell(child: Text('15085', style: style)),
                    ]),
                    TableRow(children: [
                      TableCell(child: Text('Invoice Date', style: style)),
                      TableCell(
                          child: Text(
                              DateFormat('M/d/yyyy').format(DateTime.now()),
                              style: style)),
                    ]),
                    TableRow(children: [
                      TableCell(child: Text('Due Date', style: style)),
                      TableCell(
                          child: Text(
                              DateFormat('M/d/yyyy').format(DateTime.now()),
                              style: style)),
                    ]),
                    TableRow(children: [
                      TableCell(child: Text('Billing Questions', style: style)),
                      TableCell(
                          child: Text('800-803-5003 Option 4', style: style)),
                    ])
                  ],
                ))
          ],
        ),
      ),
    ],
  );
}

Widget createItManagementScopeWidget(Page agents) {
  final servers = agents.data.firstWhere((it) => it.kind == 'Servers');
  final workstations =
      agents.data.firstWhere((it) => it.kind == 'Workstations');
  return Column(
    children: [
      Row(children: [
        Text(
          'IT Management Scope',
          style: style.copyWith(fontWeight: FontWeight.bold),
        )
      ]),
      ColoredBox(
        color: Color.fromARGB(255, 197, 189, 151),
        child: Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(children: [
              Expanded(
                  flex: 5,
                  child: Text(
                    'Service Period',
                    style: style,
                  )),
              Expanded(
                  flex: 5,
                  child: Text(
                    DateFormat('MMMM of yyyy').format(DateTime.now()),
                    style: style,
                  ))
            ])),
      ),
      ColoredBox(
        color: Color.fromARGB(255, 197, 189, 151),
        child: Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(children: [
              Expanded(
                  flex: 5,
                  child: Text(
                    'Servers Managed',
                    style: style,
                  )),
              Expanded(
                  flex: 5,
                  child: Text(
                    servers.count.toString(),
                    style: style,
                  )),
            ])),
      ),
      ColoredBox(
        color: Color.fromARGB(255, 197, 189, 151),
        child: Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(children: [
              Expanded(
                  flex: 5,
                  child: Text(
                    'Workstations Managed',
                    style: style,
                  )),
              Expanded(
                  flex: 5,
                  child: Text(
                    workstations.count.toString(),
                    style: style,
                  )),
            ])),
      ),
    ],
  );
}

Widget createItManagementResultsWidget(patches) {
  return Column(
    children: [
      Row(children: [
        Text(
          'IT Management Results',
          style: style.copyWith(fontWeight: FontWeight.bold),
        )
      ]),
      ColoredBox(
        color: Color.fromARGB(255, 145, 201, 221),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Row(children: [
            Expanded(
                flex: 5,
                child: Text(
                  'Microsoft Security Patches Installed',
                  style: style,
                )),
            Expanded(
                flex: 5,
                child: Text(
                  patches.toString(),
                  style: style,
                )),
          ]),
        ),
      ),
    ],
  );
}

Future<Page> fetchAgents() async {
  final String query = '''
    SELECT
        if(position(OSInfo, 'Server Standard') > 0, 'Servers', 'Workstations') AS Kind,
        count(*) as Count
    FROM agents
    GROUP BY Kind
    FORMAT JSON
  ''';
  final response =
      await get(Uri.http('192.168.0.102:8123', '', {"query": query}));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Page.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load statistics');
  }
}

Future<int> fetchInstalledPatches() async {
  final String query = '''
    SELECT count(*)
    FROM patch_history
    WHERE PatchState = 1
  ''';
  final response =
      await get(Uri.http('192.168.0.102:8123', '', {"query": query}));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return int.parse(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load statistics');
  }
}

class Page {
  final List<ColumnMeta> meta;
  final List<AgentStat> data;
  final int rows;
  final Statistics statistics;

  Page(
      {@required this.meta,
      @required this.data,
      @required this.rows,
      @required this.statistics});

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
        meta: json['meta']
            .map<ColumnMeta>((it) => ColumnMeta.fromJson(it))
            .toList(),
        data: json['data']
            .map<AgentStat>((it) => AgentStat.fromJson(it))
            .toList(),
        rows: json['rows'],
        statistics: Statistics.fromJson(json['statistics']));
  }
}

class Statistics {
  final double elapsed;
  final int rowsRead;
  final int bytesRead;

  Statistics(
      {@required this.elapsed,
      @required this.rowsRead,
      @required this.bytesRead});

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
        elapsed: json['elapsed'],
        rowsRead: json['rows_read'],
        bytesRead: json['bytes_Read']);
  }
}

class ColumnMeta {
  final String name;
  final String type;

  ColumnMeta({@required this.name, @required this.type});

  factory ColumnMeta.fromJson(Map<String, dynamic> json) {
    return ColumnMeta(name: json['name'], type: json['type']);
  }
}

class AgentStat {
  final String kind;
  final int count;

  AgentStat({@required this.kind, @required this.count});

  factory AgentStat.fromJson(Map<String, dynamic> json) {
    return AgentStat(kind: json['Kind'], count: int.parse(json['Count']));
  }
}
