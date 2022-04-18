// ignore_for_file: non_constant_identifier_names

// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// import 'package:intl/intl.dart';
import './time_stamp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('main画面のタイトルバー'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('ボタン'),
          //★２ 画面遷移のボタンイベント
          onPressed: () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const TimeStampPage();
          })),
          //★２追加ここまで
        ),
      ),
    );
  }
}
