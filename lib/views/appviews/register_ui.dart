// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:fitstindex_mobileapp/views/appviews/user_login_ui.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterUi extends StatefulWidget {
  const RegisterUi({super.key});

  @override
  State<RegisterUi> createState() => _RegisterUiState();
}

class _RegisterUiState extends State<RegisterUi> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordconfirmedController = TextEditingController();

  String _errorMessage = "";
  String _errorMessagePassword = "";

  bool _emailValid = false;
  bool _passwordValid = false;
  bool _isLoading = false; // สถานะการโหลดข้อมูล
  bool _isObscure = true;
  bool _isObscured = true;
  // สร้างการตรวจสอบ Email ว่าใส่ได้ถูกต้องหรือไม่
  void _validateEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@(gmail\.com|hotmail\.com|live\.com|yahoo\.com)$',
    );
    setState(() {
      if (_emailController.text.isEmpty == true) {
        _errorMessage = "กรุณาใส่ Email ด้วย ";
        _emailValid = false;
      } else if (!emailRegExp.hasMatch(email)) {
        _errorMessage = "รูปแบบ Email ไม่ถูกต้อง , Ex \"example@gmail.com\"";
        _emailValid = false;
      } else {
        _errorMessage = "";
        _emailValid = true;
      }
    });
  }

  // สร้างการตรวจสอบ Password ว่าใส่ตรงกันหรือไม่
  void _validatePassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
    setState(() {
      if (_passwordController.text != _passwordconfirmedController.text) {
        _errorMessagePassword = "กรุณาใส่ Password ให้ตรงกัน";
        _passwordValid = false;
      } else if (!passwordRegExp.hasMatch(password)) {
        _errorMessagePassword =
            "Password ต้องมีอักษรพิมพ์เล็ก, พิมพ์ใหญ่ และตัวเลข";
        _passwordValid = false;
      } else {
        _errorMessagePassword = "";
        _passwordValid = true;
      }
    });
  }

// ตรวจสอบความถูกต้องของ email และ password
  Future<void> _register() async {
    if (!_emailValid || !_passwordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาตรวจสอบข้อมูลให้ถูกต้อง'),
        ),
      );
      return;
    }

    setState(
      () {
        _isLoading = true; // เริ่มการโหลดข้อมูล
      },
    );
    try {
      // เข้ารหัสรหัสผ่าน  ** จะไม่เข้ารหัสที่ฝั่ง Client แต่ให้ไปเข้ารหัสที่ฝั่ง server แทน
      // final bytes = utf8
      //     .encode(_userPasswordController.text); // Convert password to bytes
      // final digest = sha256.convert(bytes); // SHA-256 hash
      // final passwordHash = digest.toString(); // Convert hash to string

      final response = await http.post(
        Uri.parse('${CallAPI.hostURL}/register'), // IP Server at Work
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          <String, String>{
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        ),
      );

      if (response.statusCode == 201) {
        // ปรับเปลี่ยนรหัสสถานะเป็น 201 (Created) ถ้าการลงทะเบียนสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลงทะเบียนเรียบร้อยแล้ว'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserLoginUi(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Failed: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      //เมื่อ server ไม่ตอบสนอง
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // เสร็จสิ้นการโหลดข้อมูล
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.cyan[800],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                    ),
                    Text(
                      "Registration",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        color: Colors.cyan[800],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.0175,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.name,
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
                      Icons.person_sharp,
                      size: MediaQuery.of(context).size.height * 0.030,
                      color: Colors.cyan[800],
                    ),
                    hintText: "Name",
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
                    "Email Address",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.0175,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                TextField(
                  controller: _emailController,
                  onChanged: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                    color: Colors.cyan[800],
                  ),
                  decoration: InputDecoration(
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
                  onChanged: _validatePassword,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Confirm Password",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.0175,
                      color: Colors.cyan[800],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                TextField(
                  controller: _passwordconfirmedController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _isObscured,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                    color: Colors.cyan[800],
                  ),
                  decoration: InputDecoration(
                    errorText: _errorMessagePassword.isEmpty
                        ? null
                        : _errorMessagePassword,
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
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                    hintText: "Password",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: _validatePassword,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                ),
                ElevatedButton(
                  onPressed: _emailValid && _passwordValid && !_isLoading
                      ? _register
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1,
                      vertical: MediaQuery.of(context).size.height * 0.015,
                    ),
                    backgroundColor: Colors.cyan[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * 0.975,
                      MediaQuery.of(context).size.height * 0.065,
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Register',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            color: Colors.white,
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
