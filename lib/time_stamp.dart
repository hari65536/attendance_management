// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, unrelated_type_equality_checks

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'main.dart';

class TimeStampPage extends ConsumerStatefulWidget {
  const TimeStampPage({Key? key}) : super(key: key);

  // final String title;

  @override
  _TimeStampPageState createState() => _TimeStampPageState();
}

class _TimeStampPageState extends ConsumerState<TimeStampPage> {
  // 現在時刻
  String current_time = '';
  // 出勤時間
  String attendance_time = '';
  // 退勤時間
  String leave_time = '';
  // ステータス
  String state = '勤務外';
  var _timer;

  // Datatimeformat
  var formatter = DateFormat('yyyy/MM/dd HH:mm:ss');

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
    final Attend = ref.watch(AttendTime.notifier);
    final working = ref.watch(Working.notifier);
    final resting = ref.watch(Resting.notifier);
    final Leave = ref.watch(LeaveTime.notifier);
    final restStartTimes = ref.watch(RestStartTimes.notifier);
    final restFinishTimes = ref.watch(RestFinishTimes.notifier);
    final restCount = ref.watch(RestCount.notifier);
    final create_at = ref.watch(Create_at.notifier);
    final status = ref.watch(Status.notifier);
    final user = ref.watch(UserName.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('打刻画面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '現在のステータス',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              status.state,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 32),
            const Text(
              '現在時刻',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              current_time,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 16),
            const Text(
              '勤務開始',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              attendance_time,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 8),
            const Text(
              '勤務終了',
              style: TextStyle(
                fontSize: 20,
              ),
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
                    onPressed: working.state == true
                        ? null
                        // ボタンをクリックした時の処理
                        : () async {
                            Attend.state = DateTime.now().toIso8601String();
                            working.state = true;
                            create_at.state = FieldValue.serverTimestamp();
                            status.state = '勤務中';
                            setState(() {
                              attendance_time =
                                  DateFormat('HH:mm').format(DateTime.now());
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
                    onPressed: (working.state == false || resting.state == true)
                        ? null
                        : () async {
                            working.state = false;
                            Leave.state = DateTime.now().toIso8601String();
                            status.state = '勤務終了';
                            setState(() {
                              leave_time =
                                  DateFormat('HH:mm').format(DateTime.now());
                            });
                            await FirebaseFirestore.instance
                                .collection(user.state)
                                .doc(DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()))
                                .set({
                              'name': user.state,
                              'attendance': Attend.state,
                              'rest_start': restStartTimes.state,
                              'rest_finish': restFinishTimes.state,
                              'leave': Leave.state,
                              'rest_count': restCount.state,
                              'createdAt': create_at.state
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
                    onPressed: (working.state == false || resting.state == true)
                        ? null
                        : () async {
                            resting.state = true;
                            restStartTimes.state
                                .add(DateTime.now().toIso8601String());
                            status.state = '休憩中';
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
                    onPressed: resting.state == false
                        ? null
                        : () async {
                            resting.state = false;
                            restFinishTimes.state
                                .add(DateTime.now().toIso8601String());
                            restCount.state = restCount.state + 1;
                            status.state = '勤務中';
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
