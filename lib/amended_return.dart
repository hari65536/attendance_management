// ignore_for_file: must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'main.dart';

class AmendedReturnPage extends ConsumerStatefulWidget {
  const AmendedReturnPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AmendedReturnPage> createState() => _AmendedReturnPageState();
}

// 申請一覧
class _AmendedReturnPageState extends ConsumerState<AmendedReturnPage> {
  var formatter = DateFormat('HH:mm');
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay selectedTime = const TimeOfDay(hour: 0, minute: 0);

  DateTime attendance_time = DateTime.utc(3000, 1, 1);
  DateTime leave_time = DateTime.utc(3000, 1, 1);
  DateTime rest_start = DateTime.utc(3000, 1, 1);
  DateTime rest_finish = DateTime.utc(3000, 1, 1);

  String inputText = '';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(UserName.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('勤務時間の修正申請'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // カレンダーの表示
            TableCalendar(
              // 以下必ず設定が必要
              locale: 'ja_JP',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: const Text(
                '修正したい日をカレンダーから選択してください.',
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy/MM/dd').format(_focusedDay),
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    // 勤務開始時刻
                    const Text(
                      '勤務開始',
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(attendance_time),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _selectTime_attend(context);
                      },
                      child: const Text("時刻入力"),
                    ),
                    const SizedBox(height: 16),
                    // 休憩開始時刻
                    const Text(
                      '休憩開始時間',
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(rest_start),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _selectTime_rest_start(context);
                      },
                      child: const Text("時刻入力"),
                    ),
                  ],
                ),
                const SizedBox(width: 64),
                Column(
                  children: [
                    const Text(
                      '勤務終了',
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(leave_time),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _selectTime_leave(context);
                      },
                      child: const Text("時刻入力"),
                    ),
                    const SizedBox(height: 16),
                    //　休憩時間記録用
                    const Text(
                      '休憩終了時間',
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(rest_finish),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _selectTime_rest_finish(context);
                      },
                      child: const Text("時刻入力"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 400,
              child: TextField(
                enabled: true,
                onChanged: (text) {
                  setState(() {
                    inputText = text;
                  });
                },
                decoration: const InputDecoration(
                  labelText: '申請理由',
                  hintText: '(例) 打刻忘れのため',
                  labelStyle: TextStyle(color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(width: 1, color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(width: 1, color: Colors.blue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              width: 128,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, //ボタンの背景色
                ),
                // 全ての項目に入力している場合のみ申請可能になる
                onPressed: (attendance_time == DateTime.utc(3000, 1, 1) ||
                        leave_time == DateTime.utc(3000, 1, 1) ||
                        rest_start == DateTime.utc(3000, 1, 1) ||
                        rest_finish == DateTime.utc(3000, 1, 1) ||
                        inputText == '')
                    ? null
                    : () async {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text("確認"),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Column(
                                        children: const <Widget>[
                                          Text('申請を送信してよろしいですか?'),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  // ボタン領域
                                  TextButton(
                                    child: const Text("OK"),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('amended_return')
                                          .doc(DateFormat('yyyy-MM-dd')
                                              .format(attendance_time))
                                          .set({
                                        'name': user.state,
                                        'attendance':
                                            attendance_time.toIso8601String(),
                                        'rest_start': [
                                          rest_start.toIso8601String()
                                        ],
                                        'rest_finish': [
                                          rest_finish.toIso8601String()
                                        ],
                                        'leave': leave_time.toIso8601String(),
                                        'rest_count': 1,
                                        'createdAt':
                                            Timestamp.fromDate(attendance_time),
                                        'reason': inputText,
                                        'approval': false,
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                child: const Text('申請'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 任意の時刻指定用の関数
  // 本当は引数を変えて使いまわせばいいはずだけど,その書き方がわからなかったので,出勤/退勤/休憩開始/休憩終了ごとに4つの関数がある.
  _selectTime_attend(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.input,
        builder: (context, childWidget) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  // 24時間表記の設定をtrueに
                  alwaysUse24HourFormat: true),
              child: childWidget!);
        },
        cancelText: 'キャンセル',
        hourLabelText: '時',
        minuteLabelText: '分',
        helpText: '勤務開始時刻');
    if (timeOfDay != null) {
      setState(() {
        selectedTime = timeOfDay;
        attendance_time = DateTime(_focusedDay.year, _focusedDay.month,
            _focusedDay.day, selectedTime.hour, selectedTime.minute);
      });
    }
  }

  _selectTime_leave(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.input,
        builder: (context, childWidget) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: childWidget!);
        },
        cancelText: 'キャンセル',
        hourLabelText: '時',
        minuteLabelText: '分',
        helpText: '勤務開始時刻');
    if (timeOfDay != null) {
      setState(() {
        selectedTime = timeOfDay;
        leave_time = DateTime(_focusedDay.year, _focusedDay.month,
            _focusedDay.day, selectedTime.hour, selectedTime.minute);
      });
    }
  }

  _selectTime_rest_start(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.input,
        builder: (context, childWidget) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: childWidget!);
        },
        cancelText: 'キャンセル',
        hourLabelText: '時',
        minuteLabelText: '分',
        helpText: '勤務開始時刻');
    if (timeOfDay != null) {
      setState(() {
        selectedTime = timeOfDay;
        rest_start = DateTime(_focusedDay.year, _focusedDay.month,
            _focusedDay.day, selectedTime.hour, selectedTime.minute);
      });
    }
  }

  _selectTime_rest_finish(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.input,
        builder: (context, childWidget) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: childWidget!);
        },
        cancelText: 'キャンセル',
        hourLabelText: '時',
        minuteLabelText: '分',
        helpText: '勤務開始時刻');
    if (timeOfDay != null) {
      setState(() {
        selectedTime = timeOfDay;
        rest_finish = DateTime(_focusedDay.year, _focusedDay.month,
            _focusedDay.day, selectedTime.hour, selectedTime.minute);
      });
    }
  }
}
