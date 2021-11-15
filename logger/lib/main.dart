import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:logcat/logcat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dropbox_client/dropbox_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _logs = 'Nothing yet';
  String dropbox_clientId = 'xju4jqzi4us2mnb';
  String dropbox_key =
      'ALaeVs3NDlcAAAAAAAAAAfaesakFJkORqq_aRAj86QpnGXyf4oyhQUCFFgHDohUp';
  String dropbox_secret = '4q49u76ztkxo4wz';
  String? accessToken =
      'ALaeVs3NDlcAAAAAAAAAAfaesakFJkORqq_aRAj86QpnGXyf4oyhQUCFFgHDohUp';
  @override
  initState() {
    super.initState();
    initDropbox();
    _getLogs();
  }

  Future<bool> checkAuthorized(bool authorize) async {
    final token = await Dropbox.getAccessToken();
    if (token != null) {
      if (accessToken == null || accessToken!.isEmpty) {
        accessToken = token;
      }
      return true;
    }
    if (authorize) {
      if (accessToken != null && accessToken!.isNotEmpty) {
        await Dropbox.authorizeWithAccessToken(accessToken!);
        final token = await Dropbox.getAccessToken();
        if (token != null) {
          print('authorizeWithAccessToken!');
          return true;
        }
      } else {
        await Dropbox.authorize();
        print('authorize!');
      }
    }
    return false;
  }

  Future initDropbox() async {
    if (dropbox_key == 'dropbox_key') {
      return;
    }

    await Dropbox.init(dropbox_clientId, dropbox_key, dropbox_secret);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(seconds: 20), (timer) {
      print("reload");
      _getLogs();
    });
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.red, width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Text(
                  _logs,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    print(file.path);
    await file.writeAsString(text);
    if (await checkAuthorized(true)) {
      var filepath = file.path;

      final result =
          await Dropbox.upload(filepath, '/my_file.txt', (uploaded, total) {
        print('progress $uploaded / $total');
      });
      print(result);
    }
  }

  Future<void> _getLogs() async {
    final String logs = await Logcat.execute();
    setState(() {
      _logs = logs;
    });
    _write(_logs);
  }
}
