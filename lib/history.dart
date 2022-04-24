// ignore_for_file: must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables, unused_local_variable, unnecessary_string_interpolations

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'main.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

// 勤務履歴
class _HistoryPageState extends ConsumerState<HistoryPage> {
  var formatter = DateFormat('yyyy/MM/dd (E)', 'ja');
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime view_month_start =
      DateTime(DateTime.now().year, DateTime.now().month, 1, 0, 0);
  DateTime view_month_end =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 1, 0, 0);

  @override
  Widget build(BuildContext context) {
    // 保持しているユーザー名からそのユーザーの勤務記録のみを抽出する
    final user = ref.watch(UserName.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('勤務履歴'),
      ),
      body: Column(
        children: [
          // カレンダーの表示
          TableCalendar(
            // 設定
            locale: 'ja_JP',
            // カレンダーの描画範囲.とりあえず2020-2029までの10年間表示させておく.
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            // カレンダーの月の表示が変更されたとき,その月の勤務記録を取得する
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
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${view_month_start.year}年${view_month_start.month}月の勤務履歴一覧',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            // StreamBuilderにするとリアルタイムでのデータの更新が行われる
            child: StreamBuilder<QuerySnapshot>(
              // データ一覧を取得（非同期処理）
              // 投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection(user.state)
                  .orderBy('createdAt')
                  .startAt([view_month_start]).endAt(
                      [view_month_end]).snapshots(),
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
                          subtitle: Text(
                              '${DateFormat('HH:mm').format(AttendTime)} - ${DateFormat('HH:mm').format(LeaveTime)}'),
                          // タイルをクリックすると詳細を表示
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text("勤務詳細"),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
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
                                      ],
                                    ),
                                  ),
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
