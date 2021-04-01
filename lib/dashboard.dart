import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';

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
      body: FutureBuilder<Page>(
        future: fetchAgents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Table(
              children: snapshot.data.data.map((agent) {
                return TableRow(children: [Text(agent.kind)]);
              }).toList(),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return null;
        },
      ),
    );
  }
}

Future<Page> fetchAgents() async {
  final String query = '''
    SELECT
        if(position(OSInfo, 'Server Standard') > 0, 'Server', 'Workstation') AS Kind,
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
