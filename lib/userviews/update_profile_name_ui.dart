// ignore_for_file: annotate_overrides, prefer_const_constructors, use_build_context_synchronously, unused_element, sort_child_properties_last, avoid_unnecessary_containers

import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:fitstindex_mobileapp/userviews/select_update_profile_ui.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileNameUi extends StatefulWidget {
  const UpdateProfileNameUi({super.key});

  @override
  State<UpdateProfileNameUi> createState() => _UpdateProfileNameUiState();
}

class _UpdateProfileNameUiState extends State<UpdateProfileNameUi> {
  Map<String, dynamic>? userData;
  final _updateNameController = TextEditingController();
  String _errorMessage = "";
  bool _updateNameButton = false;

  void initState() {
    super.initState();
    loadUserData();
  }

  // ฟังก์ชันสําหรับดึงข้อมูลผู้ใช้
  Future<void> loadUserData() async {
    final data = await fetchUserData(context);
    //ตรวจสอบข้อมูลผู้ใช้ถ้ามีข้อมูล
    if (data != null && mounted) {
      setState(() {
        userData = data;
      });
    }
  }

  // สร้างการตรวจสอบชื่อใส่ได้แค่ A-Z และ ตัวเลขเท่านั้น
  void _validateNamed(String name) {
    final nameRegExp =
        RegExp(r'^[\u0E00-\u0E7Fa-zA-Z]+[\u0E00-\u0E7Fa-zA-Z0-9]*$');
    setState(() {
      if (name.isEmpty || name.length < 4) {
        _errorMessage = "ชื่อมีต้องมี 4 ตัวอักษรขึ้นไป";
      } else if (!nameRegExp.hasMatch(name)) {
        if (RegExp(r'^\d').hasMatch(name)) {
          _errorMessage = "ห้ามขึ้นต้นด้วยตัวเลข";
        } else if (RegExp(r'[^\u0E00-\u0E7Fa-zA-Z0-9]').hasMatch(name)) {
          _errorMessage = "ห้ามใส่อักขระพิเศษ";
        } else if (RegExp(r'^[\u0E00-\u0E7Fa-zA-Z]*\d+[\u0E00-\u0E7Fa-zA-Z]')
            .hasMatch(name)) {
          _errorMessage = "ห้ามมีตัวเลขนำหน้าตัวอักษร";
        } else {
          _errorMessage =
              "ชื่อสามารถมีเฉพาะตัวอักษรภาษาไทย, A-Z, a-z และตัวเลขเท่านั้น";
        }
        _updateNameButton = false;
      } else {
        _errorMessage = "";
        _updateNameButton = true;
      }
    });
  }

  Future<void> _updatename() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    try {
      final response = await http.post(
        Uri.parse('${CallAPI.hostURL}/updatename'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          <String, String>{
            'username': _updateNameController.text,
          },
        ),
      );
      if (response.statusCode == 200) {
        // แสดง ข้อความ เมื่ออัปเดตชื่อสำเร็จ
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "แก้ไขเรียบร้อยแล้ว",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                  color: Colors.cyan[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "คุณได้เปลี่ยนชื่อเรียบร้อยแล้ว",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.018,
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Divider(),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // ปิด AlertDialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectUpdateProfileUi(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.cyan[800], // กำหนดสีพื้นหลัง
                      shadowColor: Colors.black, // กำหนดเงาสีดำ
                      elevation: 5,
                      fixedSize: Size(
                        MediaQuery.of(context).size.width *
                            0.25, // กำหนดความกว้าง
                        MediaQuery.of(context).size.height *
                            0.06, // กำหนดความสูง
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // กำหนดมุมปุ่มมน
                      ),
                    ),
                    child: Text(
                      "ตกลง",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ไม่สามารถแก้ไขชื่อได้ กรุณาลองใหม่ภายหลัง"),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("e:$error"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.08,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectUpdateProfileUi(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.cyan[800],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.08,
                        left: MediaQuery.of(context).size.width * 0.25,
                      ),
                      child: Text(
                        "แก้ไขชื่อที่แสดง",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.022,
                          color: Colors.cyan[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyan, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  // กำหนดความมนของมุม
                ),
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.08,
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.025,
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.06,
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.025,
                  bottom: MediaQuery.of(context).size.width * 0.09,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ชื่อที่แสดง",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Text(
                      userData?['username'] ?? 'ไม่มีข้อมูลผู้ใช้',
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Divider(
                      color: Colors.cyan,
                      thickness: 1,
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Text(
                      "แก้ไขชื่อที่แสดง",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
                    ),
                    TextField(
                      controller: _updateNameController,
                      onChanged: _validateNamed,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
                      decoration: InputDecoration(
                        errorText: _errorMessage.isEmpty ? null : _errorMessage,
                        errorStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.018,
                          color: Colors.redAccent,
                        ),
                        prefixIcon: Icon(
                          Icons.edit_note,
                          color: Colors.cyan[800],
                        ),
                        hintText: "ชื่อที่แสดงใหม่",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: MediaQuery.of(context).size.height * 0.019,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.cyan,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.cyan,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.05,
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.025,
                ),
                child: ElevatedButton(
                  onPressed: _updateNameButton ? _updatename : null,
                  child: Text(
                    "บันทึก",
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
                      MediaQuery.of(context).size.width * 1,
                      MediaQuery.of(context).size.height * 0.06,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
