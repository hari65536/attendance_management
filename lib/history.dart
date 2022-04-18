// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

// チャット画面用Widget
class _HistoryPageState extends State<HistoryPage> {
  var formatter = DateFormat('yyyy/MM/dd (E)', 'ja');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.logout),
        //     onPressed: () async {
        //       // ログアウト処理
        //       // 内部で保持しているログイン情報等が初期化される
        //       // （現時点ではログアウト時はこの処理を呼び出せばOKと、思うぐらいで大丈夫です）
        //       await FirebaseAuth.instance.signOut();
        //       // ログイン画面に遷移＋チャット画面を破棄
        //       await Navigator.of(context).pushReplacement(
        //         MaterialPageRoute(builder: (context) {
        //           return LoginPage();
        //         }),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Text('ログイン情報:'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: FutureBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              future: FirebaseFirestore.instance
                  .collection('user1')
                  .orderBy('attendance')
                  .get(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      final AttendTime = DateTime.parse(document['attendance']);
                      final LeaveTime = DateTime.parse(document['leave']);
                      // var s = 1;
                      // while (s > 0) {}
                      return Card(
                        child: ListTile(
                          title: Text(
                              formatter.format(DateTime.parse(document.id))),
                          subtitle: Text(document['leave']),
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
                                        const Text('third line'),
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
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () async {
      //     // 投稿画面に遷移
      //     await Navigator.of(context).push(
      //       MaterialPageRoute(builder: (context) {
      //         return AddPostPage(this.user);
      //       }),
      //     );
      //   },
      // ),
    );
  }
}
