import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 出勤時間
  // ignore: non_constant_identifier_names
  DateTime attendance_time = DateTime.now();
  // 退勤時間
  // ignore: non_constant_identifier_names
  DateTime leave_time = DateTime.now();
  // 休憩開始時間
  // ignore: non_constant_identifier_names
  DateTime rest_time = DateTime.now();
  // 休憩終了
  // ignore: non_constant_identifier_names
  DateTime resume_time = DateTime.now();
  bool working = false;
  bool resting = false;

  // ignore: non_constant_identifier_names
  void get_current_time(now) {
    setState(() {
      now = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '出勤時刻',
            ),
            Text(
              DateFormat('yyyy-MM-dd(E) hh:mm').format(attendance_time),
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 8),
            const Text(
              '退勤時刻',
            ),
            Text(
              DateFormat('yyyy-MM-dd(E) hh:mm').format(leave_time),
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
                        : () {
                            setState(() {
                              working = true;
                              attendance_time = DateTime.now();
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
                        : () {
                            setState(() {
                              working = false;
                              leave_time = DateTime.now();
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
                        : () {
                            setState(() {
                              resting = true;
                              attendance_time = DateTime.now();
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
                        : () {
                            setState(() {
                              resting = false;
                              leave_time = DateTime.now();
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
