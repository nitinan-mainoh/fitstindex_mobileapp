import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:fitstindex_mobileapp/userviews/update_profile_image_ui.dart';
import 'package:fitstindex_mobileapp/userviews/update_profile_name_ui.dart';
import 'package:fitstindex_mobileapp/views/index_ui.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class SelectUpdateProfileUi extends StatefulWidget {
  const SelectUpdateProfileUi({super.key});

  @override
  State<SelectUpdateProfileUi> createState() => _SelectUpdateProfileUiState();
}

class _SelectUpdateProfileUiState extends State<SelectUpdateProfileUi> {
  Map<String, dynamic>? userData;
  @override
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.08,
                          // right: MediaQuery.of(context).size.width * 0.2,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IndexUi(pageSelected: 3),
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
                          "แก้ไขโปรไฟล์",
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022,
                            color: Colors.cyan[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.025,
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.025,
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.010,
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.025,
                  bottom: MediaQuery.of(context).size.height * 0.010,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyan, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "รูปโปรไฟล์",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.20,
                            height: MediaQuery.of(context).size.height * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow()],
                            ),
                            child: userData?['profile_image'] != null
                                ? Image.memory(base64Decode(userData![
                                    'profile_image'])) // แสดงรูปจาก URL
                                : Image.asset(
                                    'assets/images/profile/default.png'), // รูปโปรไฟล์เริ่มต้น
                          ),
                          Container(
                              child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateProfileImageUi(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.cyan[800],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.010,
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.025,
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.016,
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.025,
                  bottom: MediaQuery.of(context).size.height * 0.016,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyan, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ชื่อที่แสดง",
                      style: TextStyle(
                        color: Colors.cyan[800],
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Center(
                            child: Text(
                              userData?['username'] ?? 'ไม่มีข้อมูลผู้ใช้',
                              style: TextStyle(
                                color: Colors.cyan[800],
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.019,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.025,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateProfileNameUi(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.cyan[800],
                              ),
                            ),
                          ),
                        ],
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
