// ignore_for_file: prefer_const_constructors, annotate_overrides, use_build_context_synchronously

import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:fitstindex_mobileapp/userviews/select_update_profile_ui.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileImageUi extends StatefulWidget {
  const UpdateProfileImageUi({super.key});

  @override
  State<UpdateProfileImageUi> createState() => _UpdateProfileImageUiState();
}

class _UpdateProfileImageUiState extends State<UpdateProfileImageUi> {
  Map<String, dynamic>? userData;
  String? selectedImagePath;
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

  void _showImagePickerSheet(BuildContext context) {
    final List<String> imagePaths = [
      "assets/images/profile/profile1.png",
      "assets/images/profile/profile2.png",
      "assets/images/profile/profile3.png",
      "assets/images/profile/profile4.png",
      "assets/images/profile/profile5.png",
      "assets/images/profile/profile6.png",
      "assets/images/profile/profile7.png",
      "assets/images/profile/profile8.png",
      "assets/images/profile/profile9.png",
      "assets/images/profile/profile10.png",
      "assets/images/profile/profile11.png",
      "assets/images/profile/profile12.png",
      "assets/images/profile/profile13.png",
      "assets/images/profile/profile14.png",
      "assets/images/profile/profile15.png",
      "assets/images/profile/profile16.png",
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0), // ปรับมุมมนของด้านบนให้น้อยลง
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.4,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // จำนวนคอลัมน์ต่อแถว
              crossAxisSpacing: 15, // ระยะห่างระหว่างคอลัมน์
              mainAxisSpacing: 20, // ระยะห่างระหว่างแถว
            ),
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return _buildImageOption(imagePaths[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildImageOption(String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImagePath = imagePath;
        });
        Navigator.pop(context); // ปิด Bottom Sheet เมื่อเลือกรูป
      },
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _saveProfileImage() async {
    if (selectedImagePath == null) return;

    final bytes = await DefaultAssetBundle.of(context).load(selectedImagePath!);
    String base64Image = base64Encode(bytes.buffer.asUint8List());

    SharedPreferences preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');

    final response = await http.post(
      Uri.parse('${CallAPI.hostURL}/updateprofileimage'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'profile_image': base64Image,
      }),
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
                  "คุณได้เปลี่ยนรูปโปรไฟล์เรียบร้อยแล้ว",
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
                      MediaQuery.of(context).size.height * 0.06, // กำหนดความสูง
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // กำหนดมุมปุ่มมน
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
          content: Text('Failed to update profile image'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
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
                          "แก้ไขรูปโปรไฟล์",
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
                /////////////////////////////////////////////////////
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.cyan),
                    borderRadius:
                        BorderRadius.circular(10.0), // กำหนดความมนของมุม
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.08,
                    left: MediaQuery.of(context).size.width * 0.025,
                    right: MediaQuery.of(context).size.width * 0.025,
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.04,
                    left: MediaQuery.of(context).size.width * 0.025,
                    right: MediaQuery.of(context).size.width * 0.025,
                    bottom: MediaQuery.of(context).size.width * 0.07,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.height * 0.125,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: selectedImagePath != null
                            ? Image.asset(
                                selectedImagePath!) // แสดงรูปจาก assets ที่เลือก
                            : userData?['profile_image'] != null
                                ? Image.memory(base64Decode(userData![
                                    'profile_image'])) // แสดงรูปจาก base64
                                : Image.asset(
                                    'assets/images/profile/default.png'), // รูปโปรไฟล์เริ่มต้น
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.025,
                          left: MediaQuery.of(context).size.width * 0.025,
                          right: MediaQuery.of(context).size.width * 0.025,
                        ),
                        child: ElevatedButton(
                          onPressed: () => _showImagePickerSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: Colors.black,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.25,
                              MediaQuery.of(context).size.height * 0.06,
                            ),
                          ),
                          //เรียกฟังก์ชั่นแสดง sheet ให้เลือกรูปจาก assets
                          child: Text(
                            "เปลี่ยน",
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.022,
                              color: Colors.cyan[800],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /////////////////////////////////////////////////
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.05,
                    left: MediaQuery.of(context).size.width * 0.025,
                    right: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: ElevatedButton(
                    onPressed: _saveProfileImage,
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
                    child: Text(
                      "บันทึก",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        color: Colors.white,
                      ),
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
