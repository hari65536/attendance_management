// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeStampPage extends StatefulWidget {
  const TimeStampPage({Key? key}) : super(key: key);

  // final String title;

  @override
  State<TimeStampPage> createState() => _TimeStampPageState();
}

class _TimeStampPageState extends State<TimeStampPage> {
  late String AttendTime;
  late String LeaveTime;
  late List<dynamic> RestStartTimes = [];
  late List<dynamic> RestFinishTimes = [];
  late FieldValue create_at;
  int RestCount = 0;
  // 現在時刻
  String current_time = '';
  // 出勤時間
  String attendance_time = '';
  // 退勤時間
  String leave_time = '';
  // 休憩開始時間
  String rest_time = '';
  // 休憩終了
  String resume_time = '';
  // 画面遷移時に時刻表示画面を破棄するために使う変数
  var _timer;

  // Datatimeformat
  var formatter = DateFormat('yyyy/MM/dd HH:mm:ss');
  bool working = false;
  bool resting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      // 定期実行する間隔の設定.
      const Duration(milliseconds: 100),
      // 定期実行関数.
      _onTimer,
    );
  }

  @override
  void dispose() {
    // 破棄される時に停止する.
    _timer.cancel();
    super.dispose();
  }

  // 現在時刻表示用の時刻取得関数
  void _onTimer(Timer timer) {
    var now = DateTime.now();
    var formatterTime = formatter.format(now);
    setState(() {
      current_time = formatterTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打刻画面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '現在時刻',
            ),
            Text(
              current_time,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 16),
            const Text(
              '勤務開始',
            ),
            Text(
              attendance_time,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 8),
            const Text(
              '勤務終了',
            ),
            Text(
              leave_time,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  // 横幅: 128
                  width: 128,
                  // 縦幅: 64
                  height: 64,
                  // 出勤ボタン
                  child: ElevatedButton(
                    // working == false　のときのみボタン有効化
                    onPressed: working == true
                        ? null
                        // ボタンをクリックした時の処理
                        : () async {
                            setState(() {
                              working = true;
                              attendance_time =
                                  DateFormat('HH:mm').format(DateTime.now());
                              AttendTime =
                                  DateTime.now().toLocal().toIso8601String();
                              create_at = FieldValue.serverTimestamp();
                            });
                          },
                    child: const Text('出勤'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  // 横幅: 128
                  width: 128,
                  // 縦幅: 64
                  height: 64,
                  // 退勤ボタン
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, //ボタンの背景色
                    ),
                    // ボタンをクリックした時の処理
                    onPressed: (working == false || resting == true)
                        ? null
                        : () async {
                            setState(() {
                              working = false;
                              leave_time =
                                  DateFormat('HH:mm').format(DateTime.now());
                            });
                            final LeaveTime =
                                DateTime.now().toLocal().toIso8601String();
                            await FirebaseFirestore.instance
                                .collection('user1')
                                .doc(DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()))
                                .set({
                              'name': 'user1',
                              'attendance': AttendTime,
                              'rest_start': RestStartTimes,
                              'rest_finish': RestFinishTimes,
                              'leave': LeaveTime,
                              'rest_count': RestCount,
                              'createdAt': create_at
                            });
                          },
                    child: const Text('退勤'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  // 横幅: 128
                  width: 128,
                  // 縦幅: 64
                  height: 64,
                  // 出勤ボタン
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey, //ボタンの背景色
                    ),
                    // ボタンをクリックした時の処理
                    onPressed: (working == false || resting == true)
                        ? null
                        : () async {
                            setState(() {
                              resting = true;
                              rest_time = formatter.format(DateTime.now());
                              RestStartTimes.add(
                                  DateTime.now().toLocal().toIso8601String());
                            });
                          },
                    child: const Text('休憩開始'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  // 横幅: 128
                  width: 128,
                  // 縦幅: 64
                  height: 64,
                  // 退勤ボタン
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey, //ボタンの背景色
                    ),
                    // ボタンをクリックした時の処理
                    onPressed: resting == false
                        ? null
                        : () async {
                            setState(() {
                              resting = false;
                              resume_time = formatter.format(DateTime.now());
                              RestFinishTimes.add(
                                  DateTime.now().toLocal().toIso8601String());
                              RestCount += 1;
                            });
                          },
                    child: const Text('休憩終了'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
