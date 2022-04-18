// ignore_for_file: non_constant_identifier_names

import 'package:attendance_management/time_stamp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting('ja_JP');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム画面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 128,
              height: 64,
              child: ElevatedButton(
                child: const Text('履歴'),
                //★２ 画面遷移のボタンイベント
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const HistoryPage();
                })),
                //★２追加ここまで
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 128,
              height: 64,
              child: ElevatedButton(
                child: const Text('打刻'),
                //★２ 画面遷移のボタンイベント
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const TimeStampPage();
                })),
                //★２追加ここまで
              ),
            ),
          ],
        ),
      ),
    );
  }
}
