// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'package:fitstindex_mobileapp/views/appviews/user_login_ui.dart';
import 'package:fitstindex_mobileapp/views/index_ui.dart';
import 'package:flutter/material.dart';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LoginState(),
      child: FirstIndexApp(),
    ),
  );
}

class FirstIndexApp extends StatefulWidget {
  const FirstIndexApp({super.key});

  @override
  State<FirstIndexApp> createState() => _FirstIndexAppState();
}

class _FirstIndexAppState extends State<FirstIndexApp> {
  @override
  Widget build(BuildContext context) {
    // สร้างตัวแปรสําหรับเช็คสถานะการเข้าสู่ระบบ
    bool checkLoging = Provider.of<LoginState>(context).userLogin;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ตรวจสอบสถานะการเข้าสู่ระบบ 
      // ถ้าเป็นจริงให้แสดง IndexUi ถ้าเป็นเท็จให้แสดง UserLoginUi
      home: checkLoging ? IndexUi() : UserLoginUi(),
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
