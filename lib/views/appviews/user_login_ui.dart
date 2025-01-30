// ignore_for_file: unused_element, prefer_const_constructors, sort_child_properties_last, sized_box_for_whitespace, prefer_final_fields

import 'package:fitstindex_mobileapp/views/appviews/register_ui.dart';
import 'package:fitstindex_mobileapp/views/index_ui.dart';
import 'package:flutter/material.dart';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLoginUi extends StatefulWidget {
  const UserLoginUi({super.key});

  @override
  State<UserLoginUi> createState() => _UserLoginUiState();
}

class _UserLoginUiState extends State<UserLoginUi> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true; // กำหนดสะถานนะเปิดปิดการมองเห็น password
  bool _isLoading = false; // Loading state
  bool _isLoadingFP = false; // Loading state
  String _errorMessage = "";
  //สร้างการตรวจสอบ Email ว่าระบุได้ถูกต้องหรือไม่
  void _validateEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@(gmail\.com|hotmail\.com|live\.com|yahoo\.com)$',
    );
    setState(() {
      if (_emailController.text.isEmpty == true) {
        _errorMessage = "กรุณาใส่ Email ด้วย ";
      } else if (!emailRegExp.hasMatch(email)) {
        _errorMessage = "รูปแบบ Email ไม่ถูกต้อง , Ex \"example@gmail.com\"";
      } else {
        _errorMessage = "";
      }
    });
  }

  Future<void> _login() async {
    // ล้างข้อความแจ้งเตือนก่อนที่จะทําการเข้าสู่ระบบ เพื่อไม่ให้แสดงข้อความเก่า
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${CallAPI.hostURL}/login'),
        // เพิ่ม Content-Type header เพื่อบอกวาข้อมูลใน body คือ JSON
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );
      // ถ้าเข้าสู่ระบบสําเร็จจะดึง token ออกมาจาก response.body และเก็บไว้
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // บันทึก token ลงใน SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString('auth_token', token);
        // แจ้ง widgets ที่เรียกใช้ LoginState ให้เปลี่ยนแปลงสถานะ
        Provider.of<LoginState>(context, listen: false).logIn();
        //ตรวจสอบสถานะของ Widget ว่ายังคงอยู่ใน widget tree หรือไม่
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IndexUi(),
          ),
        );
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = "Email หรือ Password ไม่ถูกต้อง.";
        });
      } else {
        setState(() {
          _errorMessage = "ล็อกอินไม่สําเร็จ กรุณาลองใหม่";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "การเชื่อมต่อกับเซิร์ฟเวอร์ล้มเหลว : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (_errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
        ),
      );
    }
  }

// ฟังก์ชั่นส่งอีเมลเพื่อรีเซ็ตรหัสผ่าน
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorMessage("กรุณากรอกอีเมลเพื่อขอรหัสผ่านใหม่");
      return;
    }

    setState(() {
      _isLoadingFP = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${CallAPI.hostURL}/sendpasswordemail'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage(
            "ระบบทำการรีเซ็ตรหัสผ่านและส่งไปยัง $email เรียบร้อยแล้ว");
      } else if (response.statusCode == 404) {
        _showErrorMessage("ไม่พบอีเมลนี้ในระบบ");
      } else {
        _showErrorMessage("เกิดข้อผิดพลาด: ${response.body}");
      }
    } catch (e) {
      _showErrorMessage("ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์: $e");
    } finally {
      setState(() {
        _isLoadingFP = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.cyan[100],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Center(
            child: Text(
              'First Index',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.cyan[800],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.025,
              right: MediaQuery.of(context).size.width * 0.025,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.025,
                ),
                ClipRRect(
                  child: Image.asset(
                    'assets/icon/icon.png',
                    height: MediaQuery.of(context).size.height * 0.20,
                    width: MediaQuery.of(context).size.width * 0.47,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.025,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email Address",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.0175,
                      // fontWeight: FontWeight.bold,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                TextField(
                  controller: _emailController,
                  //ตรวจสอบการใส่ EmailAddress ของ User
                  onChanged: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                    color: Colors.cyan[800],
                  ),
                  decoration: InputDecoration(
                    //แจ้งเตือนเมื่อ User ระบุ Email ผิด Format
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    errorText: _errorMessage.isEmpty ? null : _errorMessage,
                    errorStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.018,
                      color: Colors.redAccent,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    prefixIcon: Icon(
                      Icons.email_rounded,
                      size: MediaQuery.of(context).size.height * 0.030,
                      color: Colors.cyan[800],
                    ),
                    hintText: "example@gmail.com",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.0175,
                      // fontWeight: FontWeight.bold,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObscure,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                    color: Colors.cyan[800],
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan, width: 3),
                    ),
                    prefixIcon: Icon(
                      Icons.key_rounded,
                      size: MediaQuery.of(context).size.height * 0.030,
                      color: Colors.cyan[800],
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye_rounded,
                        size: MediaQuery.of(context).size.height * 0.030,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    hintText: "Password",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.045,
                ),
                Row(
                  children: [
                    _isLoading
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.47,
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.cyan[800],
                                  strokeWidth: 5.0,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Logging in...",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.018,
                                    color: Colors.cyan[800],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _login,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022,
                                color: Colors.cyan[800],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan[200],
                              shadowColor: Colors.black,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.47,
                                MediaQuery.of(context).size.height * 0.06,
                              ),
                            ),
                          ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.02,
                    ),
                    _isLoadingFP
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.460,
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.cyan[800],
                                  strokeWidth: 5.0,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Sending email...",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.018,
                                    color: Colors.cyan[800],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              _forgotPassword();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.cyan[800]!, width: 2),
                              shadowColor: Colors.black,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.460,
                                MediaQuery.of(context).size.height * 0.06,
                              ),
                            ),
                            child: Text(
                              "Forgot Password ?",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018,
                                color: Colors.cyan[800],
                              ),
                            ),
                          ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Don't have an Account ?",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.0175,
                      // fontWeight: FontWeight.bold,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterUi(),
                      ),
                    );
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.022,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[800],
                    shadowColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * 0.975,
                      MediaQuery.of(context).size.height * 0.06,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
