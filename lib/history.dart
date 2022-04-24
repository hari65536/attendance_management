// ignore_for_file: must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables, unused_local_variable

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

// チャット画面用Widget
class _HistoryPageState extends State<HistoryPage> {
  var formatter = DateFormat('yyyy/MM/dd (E)', 'ja');
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime view_month_start =
      DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0);
  DateTime view_month_end =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 1, 0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
      ),
      body: Column(
        children: [
          // カレンダーの表示
          TableCalendar(
            // 以下必ず設定が必要
            locale: 'ja_JP',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                view_month_start =
                    DateTime(focusedDay.year, focusedDay.month, 1, 0, 0);
                view_month_end =
                    DateTime(focusedDay.year, focusedDay.month + 1, 1, 0, 0);
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
            ),
            // onPageChanged: (d) {
            //   setState(() {
            //     view_month = d.month;
            //   });
            // },
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
                '${view_month_start.year}年${view_month_start.month}月の勤務履歴一覧'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: FutureBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              future: FirebaseFirestore.instance
                  .collection('user1')
                  .orderBy('createdAt')
                  .startAt([view_month_start]).endAt([view_month_end])
                  // .where('createdAt', isGreaterThanOrEqualTo: view_month_start)
                  // .where('createdAt', isLessThan: view_month_start)
                  .get(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      // 出勤時間
                      DateTime AttendTime =
                          DateTime.parse(document['attendance']);
                      DateTime LeaveTime = DateTime.parse(document['leave']);
                      List<dynamic> RestStartTimes = document['rest_start'];
                      List<dynamic> RestFinishTimes = document['rest_finish'];
                      int RestCount = document['rest_count'];

                      var SumRestTime = 0;
                      final diff_time = LeaveTime.difference(AttendTime);
                      // 総休憩時間の計算
                      if (RestCount > 0) {
                        for (var i = 0; i < RestCount; i++) {
                          SumRestTime = DateTime.parse(RestFinishTimes[i])
                              .difference(DateTime.parse((RestStartTimes[i])))
                              .inMinutes;
                        }
                      }

                      // var s = 1;
                      // while (s > 0) {}
                      return Card(
                        child: ListTile(
                          title: Text(
                              formatter.format(DateTime.parse(document.id))),
                          // タイルをクリックすると詳細を表示
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text("勤務詳細"),
                                  content: SingleChildScrollView(
                                      child: ListBody(children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Text(
                                            '出勤時刻 ${DateFormat('HH:mm').format(AttendTime)}'),
                                        Text(
                                            '退勤時刻 ${DateFormat('HH:mm').format(LeaveTime)}'),
                                        Text(
                                            '合計勤務時間 ${diff_time.inMinutes - SumRestTime}分'),
                                        Text('休憩回数 $RestCount'),
                                        Text('総休憩時間 $SumRestTime分'),
                                        // 勤務時間が8時間を超えた場合には残業としてカウント
                                        Text(
                                            '残業時間 ${max(0, diff_time.inMinutes - SumRestTime - 480)}分')
                                      ],
                                    )
                                  ])),
                                  // content: const Text(
                                  //     "メッセージメッセージメッセージメッセージメッセージメッセージ"),
                                  actions: <Widget>[
                                    // ボタン領域
                                    TextButton(
                                      child: const Text("OK"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          // 自分の投稿メッセージの場合は削除ボタンを表示
                          trailing: document['name'] == 'user1'
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    // 投稿メッセージのドキュメントを削除
                                    await FirebaseFirestore.instance
                                        .collection('user1')
                                        .doc(document.id)
                                        .delete();
                                  },
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                }
                // データが読込中の場合
                return const Center(
                  child: Text('読込中...'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
