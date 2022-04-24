// ignore_for_file: must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables, unused_local_variable

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({Key? key}) : super(key: key);

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

// チャット画面用Widget
class _ApprovalPageState extends State<ApprovalPage> {
  var formatter = DateFormat('yyyy/MM/dd (E)', 'ja');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打刻修正の申請一覧'),
      ),
      body: Column(
        children: [
          Expanded(
            // StreamBuilderにするとリアルタイムでのデータの更新が行われる
            child: StreamBuilder<QuerySnapshot>(
              // データ一覧を取得
              // 投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection('amended_return')
                  .orderBy('createdAt')
                  .snapshots(),
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
                      // 退勤時間
                      DateTime LeaveTime = DateTime.parse(document['leave']);
                      // 休憩開始/休憩終了時間
                      List<dynamic> RestStartTimes = document['rest_start'];
                      List<dynamic> RestFinishTimes = document['rest_finish'];
                      // 打刻修正の場合は休憩回数は1として扱う
                      int RestCount = document['rest_count'];
                      Timestamp create_at = document['createdAt'];
                      // 修正申請理由
                      String Reason = document['reason'];
                      // 修正申請者の名前
                      String user_name = document['name'];

                      var SumRestTime = 0;
                      // 出勤時間と退勤時間の差を計算
                      final diff_time = LeaveTime.difference(AttendTime);
                      // 総休憩時間の計算
                      if (RestCount > 0) {
                        for (var i = 0; i < RestCount; i++) {
                          SumRestTime = DateTime.parse(RestFinishTimes[i])
                              .difference(DateTime.parse((RestStartTimes[i])))
                              .inMinutes;
                        }
                      }
                      return Card(
                        child: ListTile(
                          title: Text(
                              formatter.format(DateTime.parse(document.id))),
                          subtitle: Text(user_name),
                          // タイルをクリックすると詳細を表示
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                // AlertDialogを用いて詳細情報の表示
                                return AlertDialog(
                                  title: const Text("申請内容の詳細"),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Text('申請者 $user_name'),
                                            Text(
                                                '修正する日時 ${DateFormat("yyyy/MM/dd").format(AttendTime)}'),
                                            Text('申請理由 : $Reason'),
                                            const SizedBox(height: 8),
                                            const Text(' -- 勤務詳細 -- '),
                                            const SizedBox(height: 8),
                                            Text(
                                                '出勤時刻 ${DateFormat('HH:mm').format(AttendTime)}'),
                                            Text(
                                                '退勤時刻 ${DateFormat('HH:mm').format(LeaveTime)}'),
                                            // 合計勤務時間 = (退勤時間 - 出勤時間) - 休憩時間
                                            Text(
                                                '合計勤務時間 ${diff_time.inMinutes - SumRestTime}分'),
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
                                      child: const Text("キャンセル"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: const Text("承認"),
                                      onPressed: () async {
                                        // ダイアログの承認ボタンを押したときに,修正される.
                                        await FirebaseFirestore.instance
                                            .collection(user_name)
                                            .doc(DateFormat('yyyy-MM-dd')
                                                .format(AttendTime))
                                            .set({
                                          'name': user_name,
                                          'attendance':
                                              AttendTime.toIso8601String(),
                                          'rest_start': RestStartTimes,
                                          'rest_finish': RestFinishTimes,
                                          'leave': LeaveTime.toIso8601String(),
                                          'rest_count': RestCount,
                                          'createdAt': create_at
                                        });
                                        // 承認した後申請データは削除される
                                        await FirebaseFirestore.instance
                                            .collection('amended_return')
                                            .doc(DateFormat('yyyy-MM-dd')
                                                .format(AttendTime))
                                            .delete();
                                        Navigator.pop(context);
                                      },
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
