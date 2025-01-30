// ignore_for_file: annotate_overrides, prefer_const_constructors, sort_child_properties_last, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'dart:typed_data';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:fitstindex_mobileapp/userviews/select_update_profile_ui.dart';
import 'package:flutter/material.dart';

class UserInfoUi extends StatefulWidget {
  const UserInfoUi({super.key});

  @override
  State<UserInfoUi> createState() => _UserInfoUiState();
}

class _UserInfoUiState extends State<UserInfoUi> {
  // สร้างตัวแปรสําหรับเก็บข้อมูลผู้ใช้ ในรูปแบบ Map
  Map<String, dynamic>? userData;
  // สร้างตัวแปรสําหรับเก็บรูปภาพโปรไฟล์
  Uint8List? profileImageBytes;
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // ดึงข้อมูลผู้ใช้จาก SharedPreferences จาก ShareData
  Future<void> loadUserData() async {
    final data = await fetchUserData(context);
    // ตรวจสอบข้อมูลผู้ใช้ถ้ามีข้อมูล
    if (data != null && mounted) {
      setState(() {
        userData = data;
        // ถอดรหัสรูปภาพโดยใช้ฟังก์ชันจาก image_helper.dart
        profileImageBytes = decodeBase64Image(userData?['profile_image']);
      });
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
                child: Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.025,
                  ),
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow()],
                  ),
                  child: profileImageBytes != null
                      ? Image.memory(
                          profileImageBytes!,
                          // fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/profile/default.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              Center(
                child: Text(
                  userData?['username'] ?? 'ไม่มีข้อมูลผู้ใช้',
                  style: TextStyle(
                    color: Colors.cyan[800],
                    fontSize: MediaQuery.of(context).size.height * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.015,
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyan, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Email",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                      ),
                    ),
                    Text(
                      userData?['email'] ?? 'ไม่มีข้อมูลอีเมล',
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.015,
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyan, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "จำนวนนิยายที่เขียน",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                      ),
                    ),
                    Text(
                      "${userData?['novel_count'] ?? 0} เรื่อง",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.015,
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyan, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "จำนวนนิยายที่อยู่ในชั้น",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                      ),
                    ),
                    Text(
                      "${userData?['library_count'] ?? 0} เรื่อง",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.015,
                  horizontal: MediaQuery.of(context).size.width * 0.0,
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectUpdateProfileUi(),
                            ),
                          );
                        },
                        child: Text(
                          "แก้ไขโปรไฟล์",
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
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
                            MediaQuery.of(context).size.width * 0.43,
                            MediaQuery.of(context).size.height * 0.06,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () => logout(context),
                        child: Text(
                          "ออกจากระบบ",
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            color: Colors.cyan[800],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.black,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fixedSize: Size(
                            MediaQuery.of(context).size.width * 0.43,
                            MediaQuery.of(context).size.height * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
