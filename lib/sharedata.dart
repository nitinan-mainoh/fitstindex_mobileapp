// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:fitstindex_mobileapp/views/appviews/user_login_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:event_bus/event_bus.dart';

// ฟังก์ชั่นสำหรับเปลี่ยนแปลงสถานะการเข้าสู่ระบบ
class LoginState extends ChangeNotifier {
  // สร้างตัวแปรและกำหนดสถานะเป็น false
  bool _userLogin = false;
  // สร้างตัวแปร getter userLogin เพื่อเข้าถึงสถานะการเข้าสู่ระบบ true หรือ false
  bool get userLogin => _userLogin;

  // ฟังก์ชั่นสำหรับเปลี่ยนแปลงสถานะการเข้าสู่ระบบ (เข้าสู่ระบบ)
  void logIn() {
    // กําหนดสถานะการเข้าสู่ระบบเป็น true
    _userLogin = true;
    // แจ้ง widgets ที่เรียกใช้ LoginState ให้เปลี่ยนแปลงสถานะ
    notifyListeners();
  }

  // ฟังก์ชั่นสำหรับเปลี่ยนแปลงสถานะการเข้าสู่ระบบ (ออกจากระบบ)
  void logOut() {
    // กําหนดสถานะการเข้าสู่ระบบเป็น false
    _userLogin = false;
    // แจ้ง widgets ที่เรียกใช้ LoginState ให้เปลี่ยนแปลงสถานะ
    notifyListeners();
  }
}

//-----------------------------------------------------------------------------
class CallAPI {
  static String hostURL = 'http://192.168.56.1:3000'; // Work PC
  // static String hostURL = 'http://192.168.1.10:3000'; // Home PC
  // static String hostURL = 'http://192.168.1.15:3000'; // Home Notbook
}

// ฟังก์ชั่นสําหรับดึงข้อมูลผู้ใช้
Future<Map<String, dynamic>?> fetchUserData(BuildContext context) async {
  // ดึง token จาก SharedPreferences
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('auth_token');
  // ถ้าไม่มี token ให้ส่งกลับข้อความ error
  if (token == null) {
    return {"แจ้งเตือน": "กรุณา Login เพื่อใช้งาน"};
  }

  try {
    // เรียกใช้ API สําหรับดึงข้อมูลผู้ใช้
    final response = await http.get(
      Uri.parse('${CallAPI.hostURL}/userinfo'),
      // Uri.parse('http://192.168.1.7:3000/userinfo'),
      // เพิ่ม Authorization header พร้อมกับ token เพื่อยืนยันตัวตน
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    // หากดึงข้อมูลสําเร็จ
    if (response.statusCode == 200) {
      // แปลงข้อมูล JSON เป็น Map ที่แสดงข้อมูลผู้ใช้
      return jsonDecode(response.body);
      // หาก token ไม่ถูกต้อง
    } else if (response.statusCode == 401) {
      // จะเรียกใช้ logout() เพื่อออกจากระบบ และส่ง null กลับ
      await logout(context);
      return null;
    } else {
      // หากเกิดข้อผิดพลาดในการดึงข้อมูล
      return {"แจ้งเตือน": "ไม่พบข้อมูลผู้ใช้"};
    }
  } catch (e) {
    // หากเกิดข้อผิดพลาดในการดึงข้อมูล และแสดงข้อผิดพลาด
    return {"แจ้งเตือน": "การดึงข้อมูลผู้ใช้ล้มเหลว: $e"};
  }
}

Future<void> logout(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.remove('auth_token');

  // อัพเดตสถานะการล็อกอินใน LoginState
  Provider.of<LoginState>(context, listen: false).logOut();

  // นำทางไปยังหน้าล็อกอิน
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => UserLoginUi(),
    ),
  );
}

// ฟังก์ชันสำหรับถอดรหัส Base64 ของรูปภาพ
Uint8List? decodeBase64Image(String? base64String) {
  if (base64String == null || base64String.isEmpty) {
    return null; // กรณีไม่มีรูปภาพ
  }
  try {
    return base64Decode(base64String);
  } catch (e) {
    print("Error decoding Base64: $e");
    return null; // กรณีถอดรหัสล้มเหลว
  }
}

//ฟังก์ชั่นสำหรับนับจำนวนเมื่อตัวเลขมีจำนวน >= 1000 and >= 1000000 จะแสดงเป็น 1k , 1M
// String formatViews(int views) {
//   if (views >= 1000 && views < 1000000) {
//     //ตัวเลขที่ถูกหารแล้วจะถูกต่อท้ายด้วย k และส่งค่ากลับไปที่ views
//     //นรูปแบบ String โดยถูกกำหนดจุดทศนิยมไว้ 1 ตำแหน่ง
//     return '${(views / 1000).toStringAsFixed(1)}k';
//   } else if (views >= 1000000) {
//     return '${(views / 1000000).toStringAsFixed(1)}M';
//   } else {
//     return views.toString();
//   }
// }

String formatViews(dynamic views) {
  if (views is int) {
    return views.toString();
  } else if (views is String) {
    return views;
  } else {
    return '0';
  }
}

//------------------------------------------------------------------------------
final EventBus eventBus = EventBus();

class RefreshHomeEvent {}
