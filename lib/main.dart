// ignore_for_file: non_constant_identifier_names

import 'package:attendance_management/time_stamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'amended_return.dart';
import 'approval.dart';
import 'history.dart';

// 異なるページで共通して使う変数を定義
final UserName = Provider((ref) {});
// 打刻画面の情報を記録し,画面が遷移しても打刻が記録できるよう定義
final AttendTime = StateProvider<String>((ref) => '');
final LeaveTime = StateProvider((ref) => '');
final RestStartTimes = StateProvider((ref) => []);
final RestFinishTimes = StateProvider((ref) => []);
final RestCount = StateProvider((ref) => 0);
final Create_at =
    StateProvider<FieldValue>((ref) => FieldValue.serverTimestamp());
final Working = StateProvider<bool>((ref) => false);
final Resting = StateProvider<bool>((ref) => false);
final Status = StateProvider<String>((ref) => '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting('ja_JP');
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
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
                // 画面遷移のボタンイベント
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const HistoryPage();
                })),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 128,
              height: 64,
              child: ElevatedButton(
                child: const Text('打刻'),
                // 画面遷移のボタンイベント
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const TimeStampPage();
                })),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 128,
              height: 64,
              child: ElevatedButton(
                child: const Text('申請'),
                // 画面遷移のボタンイベント
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const AmendedReturnPage();
                })),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 128,
              height: 64,
              child: ElevatedButton(
                child: const Text('打刻修正の承認'),
                // 画面遷移のボタンイベント
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const ApprovalPage();
                })),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
