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
      await get(Uri.http('172.28.128.3:30004', '', {"query": query}));

  /*final response1 = await post(
      Uri.http("172.28.128.3:30008",
          "/auth/realms/msp/protocol/openid-connect/token"),
      body: {
        "client_id": "gateway",
        "grant_type": "password",
        "scope": "openid",
        "username": "admin",
        "password": "admin"
      });
  Token token = Token.fromJson(jsonDecode(response1.body));
  token.showToken();*/
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
      await get(Uri.http('172.28.128.3:30004', '', {"query": query}));
  /* final response = await get(Uri.parse("http://172.28.128.3:30009/api/agg/patches"),
      headers: {HttpHeaders.authorizationHeader: "Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJwQUZnZndzeGZkaFpvLTkyQWNLZnpDOFNfbWZSeXdzN2pYcEE0a1BobnlNIn0.eyJleHAiOjE2MTk1MTc3MzMsImlhdCI6MTYxOTUxNzEzMywianRpIjoiOTQ5ZGVmNDYtOTkzOC00MzBiLTg1M2UtNjQxOTUyOTI0OTE0IiwiaXNzIjoiaHR0cDovLzE3Mi4yOC4xMjguMzozMDAwOC9hdXRoL3JlYWxtcy9tc3AiLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiOTk0Mjc1MzEtNTk4MC00NDA4LWE1OTQtZmE1YmRjZWQ1Njg1IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiZ2F0ZXdheSIsInNlc3Npb25fc3RhdGUiOiJkMGIxNzI4ZS03NDU5LTQ2OTAtYTBlOS0wNmJiYWUyYzIyMGQiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbImh0dHA6Ly8xNzIuMjguMTI4LjM6MzAwMDgiXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIlJFQUQiLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJvcGVuaWQgZW1haWwgcHJvZmlsZSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwicHJlZmVycmVkX3VzZXJuYW1lIjoiYWRtaW4ifQ.DW9D8odC0Xop2hNiTjStg5ZBUVPJvB-j6z3zbh-W5WbcpZCOkESlTMeHh_ZHNVyiKz7LEWye46aHxxccR9P-feSOBPA5nSNb3GL7EreBB4_VWY3XrVk-4WgHGhHmKxONiL3MM0vZxg5UYzeh-aK4rJW7dnkp7cRnjqx_AMIDE3k8NJDVtUVcIkSGEoTSbGcRQUeB6eOPuDWSwnFXt9tWArvGXzGF8oz3tM-ARvTTFu4RJ3_og02wsE_iK_JEWWdjcURBBH8PJqQnkJK9bWZQXyTHu2yg0geyu19QGPY2DYNHaY1z6zGfwcqkCqsrIabfF3oLQQWtpVseNcid6tJXng"});
*/
  /*final test =
      await get(Uri.http('172.28.128.3:30009','/api/agg/agents', {"Authorization":
      "Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJwQUZnZndzeGZkaFpvLTkyQWNLZnpDOFNfbWZSeXdzN2pYcEE0a1BobnlNIn0.eyJleHAiOjE2MTk0NTU0ODAsImlhdCI6MTYxOTQ1NTE4MCwiYXV0aF90aW1lIjoxNjE5NDUzNzY3LCJqdGkiOiI5NGRhM2E0OS05YmVjLTQ2MWEtYjM0MS02MjhkNjcwYzYwZmIiLCJpc3MiOiJodHRwOi8vMTcyLjI4LjEyOC4zOjMwMDA4L2F1dGgvcmVhbG1zL21zcCIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiI5OTQyNzUzMS01OTgwLTQ0MDgtYTU5NC1mYTViZGNlZDU2ODUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJnYXRld2F5Iiwic2Vzc2lvbl9zdGF0ZSI6IjMzNDU3YjA2LTA3ZTEtNDRhMS04MGExLTc3MzJjZTZkZTc3MSIsImFjciI6IjEiLCJhbGxvd2VkLW9yaWdpbnMiOlsiaHR0cDovLzE3Mi4yOC4xMjguMzozMDAwOCJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiUkVBRCIsIm9mZmxpbmVfYWNjZXNzIiwidW1hX2F1dGhvcml6YXRpb24iXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6Im9wZW5pZCBlbWFpbCBwcm9maWxlIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJhZG1pbiJ9.aixGDlyw7gMdOJZcsvb4U-6HfPJ70Ph5ubnAcRPv9M4Y0QxodMQM2NgfR76hZr2C_J6JOZFU9x1ywDnkb-oBPGISjYzGWFk-bFjiIGH5SCcz1jm79-vpwR08WXdXP3wPDgE-rsI9K1VOH1nVN-K1wUVgFCZoe8RXE-NWF_uRmkvqZJf2JRKs4bwLM7RvJ9UoLk_UZe_AkoTfNEWedUVCA_rlTzwoD1O1MP802fAkE_nl6glHm8Lcw6kSekGlSz1wTSE7EO2RJ7D00ukIvgsZQOhyNLwLioVDN4gr7KmjecDZLe1XTsMIW0b30P_5_fwYJttjyn5gNO1IZovhlsoPMg"
      }));*/
  /*print(test.statusCode);
  print(test.body);*/
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

class Token{
  final String access_token;
  Token({@required this.access_token});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
        access_token: json['access_token']);
  }

  void showToken(){
    print(access_token);
  }
}
