// ignore_for_file: non_constant_identifier_names

import 'package:attendance_management/time_stamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'amended_return.dart';
import 'approval.dart';
import 'history.dart';

// 異なるページで共通して使う変数を定義
final UserName = StateProvider((ref) => '');
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
final Admin = StateProvider<bool>((ref) => false);

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
      // デフォルトでは漢字用のフォントは中国語用になるので,日本語用のフォントを使うように指定
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.sawarabiGothicTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // ダークモードに対応
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.sawarabiGothicTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String user_name = '';

  @override
  Widget build(
    BuildContext context,
  ) {
    // ユーザー名の保存
    final user = ref.watch(UserName.notifier);
    final admin = ref.watch(Admin.notifier);

    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ユーザー名
              TextFormField(
                decoration: const InputDecoration(labelText: 'ユーザー名'),
                onChanged: (String value) {
                  setState(() {
                    user_name = value;
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.all(8),
              ),
              SizedBox(
                width: double.infinity,
                // ユーザーログインボタン
                child: ElevatedButton(
                  child: const Text('ユーザーログイン'),
                  onPressed: user_name == ''
                      ? null
                      : () async {
                          user.state = user_name;
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return const MainPage();
                            }),
                          );
                        },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                // 管理者ログインボタン
                child: ElevatedButton(
                  child: const Text('管理者ログイン'),
                  onPressed: user_name == ''
                      ? null
                      : () async {
                          user.state = user_name;
                          admin.state = true;
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return const MainPage();
                            }),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends ConsumerWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(Admin.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム画面'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // ログイン画面に遷移＋ホーム画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return const LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 勤務履歴ボタン
            SizedBox(
              width: 128,
              height: 64,
              child: ElevatedButton(
                child: const Text(
                  '勤務履歴',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                // 画面遷移のボタンイベント
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const HistoryPage();
                })),
              ),
            ),
            // 調整のための空白
            const SizedBox(height: 8),
            // 打刻機能への遷移ボタン
            SizedBox(
              width: 128,
              height: 64,
              child: ElevatedButton(
                child: const Text(
                  '打刻',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
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
                child: const Text(
                  '申請',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
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
              child: Visibility(
                  child: ElevatedButton(
                    child: const Text(
                      '修正の承認',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    // 画面遷移のボタンイベント
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const ApprovalPage();
                    })),
                  ),
                  visible: admin.state),
            ),
          ],
        ),
      ),
    );
  }
}
