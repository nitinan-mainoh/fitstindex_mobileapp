// ignore_for_file: unused_element

import 'dart:async';

import 'package:fitstindex_mobileapp/novelviews/novel_content_ui.dart';
import 'package:fitstindex_mobileapp/novelviews/novel_index_ui.dart';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:fitstindex_mobileapp/views/index_ui.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class NovelInfoUi extends StatefulWidget {
  final Map<String, dynamic> novelData;
  const NovelInfoUi({super.key, required this.novelData});

  @override
  State<NovelInfoUi> createState() => _NovelInfoUiState();
}

class _NovelInfoUiState extends State<NovelInfoUi> {
  Map<String, dynamic>? userData;
  bool isAddedToLibrary = false; //สถานะการเพิ่มนิยายเข้าชั้นหนังสือ

  @override
  void initState() {
    super.initState();
    loadUserData(); // โหลดข้อมูล user
    checkNovelInLibrary(); // ตรวจสอบนิยายว่าอยู่ใน Library ของ User หรือไม่เพื่ออัพเดทสถานะของปุ่ม
    reloadNovelData();
  }

  //ฟังก์ชั่นโหลดข้อมูลผู้ใช้
  Future<void> loadUserData() async {
    final data = await fetchUserData(context);
    if (data != null && mounted) {
      setState(() {
        userData = data;
      });
    }
  }

  Future<Map<String, dynamic>?> getNovelDataByNovelId() async {
    try {
      final response = await http.get(Uri.parse(
          '${CallAPI.hostURL}/getNovelByNovelId?novel_id=${widget.novelData['novel_id']}'));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List && decodedData.isNotEmpty) {
          return decodedData[0]
              as Map<String, dynamic>; // Assuming first item contains data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data found')),
          );
          return null;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load data: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return null;
    }
  }

  Future<void> reloadNovelData() async {
    final newData = await getNovelDataByNovelId();
    if (newData != null && mounted) {
      setState(() {
        widget.novelData.addAll(newData); // อัปเดตข้อมูลใน novelData
      });
    }
  }

  // ฟังก์ชั่นแสดง Dialog แจ้งเตือน เมื่อไม่ได้ล็อกอิน
  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "กรุณาล็อกอิน",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.028,
              color: Colors.cyan[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "กรุณาล็อกอินเพื่อเข้าใช้งาน ชั้นหนังสือ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Divider(),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด Dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IndexUi(pageSelected: 3),
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () => logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[800],
                    shadowColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width *
                          0.25, // กำหนดความกว้าง
                      MediaQuery.of(context).size.height * 0.06, // กำหนดความสูง
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.022,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //ฟังก์ชั่นตรวจสอบว่านิยายนี้อยู่ใน Library ของ User หรือไม่
  Future<void> checkNovelInLibrary() async {
    //โหลด user เพื่อนำมาเช็ค นิยายใน library
    // loadUserData();
    final data = await fetchUserData(context);
    if (data != null && mounted) {
      setState(() {
        userData = data;
      });
    }
    //ตรวจสอบว่าใน Library ของ user มีนิยายหรือไม่

    final response = await http.get(
      Uri.parse(
          '${CallAPI.hostURL}/checkNovelInLibrary?user_id=${userData?['user_id']}&novel_id=${widget.novelData['novel_id']}'),
    );
    //ถ้าการตอบกลับปกติจะนำข้อมูลไปเปรียบเทียบกัน
    if (response.statusCode == 200) {
      // แปลงข้อมูล JSON เป็น List เก็บไว้ที่ตัวแปร novelsInLibrary คือชั้นหนังสือของ User
      final List<dynamic> novelsInLibrary = jsonDecode(response.body);
      // ตรวจสอบว่ามีข้อมูลที่ตรงกันหรือไม่
      // เปรียบเทียบข้อมูลกันระหว่างตัวแปร novelsInLibrary คือชั้นหนังสือของ User กับ widget.novelData คือนิยายที่ User กำลังอ่าน
      // เงื่อนไขการตรวจสอบคือ novel_id ของ novelsInLibrary ตรงกับ novel_id ของ widget.novelData
      // โดยใช้ any() เพื่อตรวจสอบว่ามีข้อมูลที่ตรงกัน
      final novelInLibrary = novelsInLibrary.any(
        (novelInlibraryData) =>
            novelInlibraryData['novel_id'] == widget.novelData['novel_id'],
      );
      //update สถานะของ isAddedToLibrary เมื่อมีข้อมูลที่ตรงกัน
      setState(() {
        isAddedToLibrary = novelInLibrary;
      });
    } else {
      //แจ้งข้อความในรูปแบบ SnackBar เมื่อกับตอบสนองจากเชิพเวอร์ไม่ใช่ 200
      const ScaffoldMessenger(
          child: SnackBar(content: Text("ไม่สามารถตรวจสอบนิยายใน Libraryได้")));
      setState(() {
        isAddedToLibrary = true;
      });
    }
  }

  //ฟังก์ชั่นสำหรับเพิ่มนิยายใน Library
  void addNovelToLibrary(Map<String, dynamic> novelData) async {
    // ตรวจสอบว่าผู้ใช้ได้ล็อกอินหรือไม่
    final loginState = Provider.of<LoginState>(context, listen: false);
    // ถ้าผู้ใช้ยังไม่ได้ล็อกอิน ให้แสดง dialog แจ้งเตือน
    if (loginState.userLogin == false) {
      _showWarningDialog(context);
      return;
    }
    final userId = userData?['user_id'];
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาล็อกอินเพื่อใช้งาน ชั้นหนังสือ")),
      );
      return;
    }
    final response = await http.post(
      Uri.parse('${CallAPI.hostURL}/addToLibrary'),
      body: jsonEncode({
        'user_id': userId,
        'novel_id': novelData['novel_id'],
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("เพิ่ม ${novelData['title']} เข้าชั้นเรียบร้อยแล้ว")),
      );
      setState(() {
        isAddedToLibrary = true; // อัพเดทสถานะนิยายใน Library
      });
    }
  }

  //ฟังก์ชั่นสำหรับลบนิยายออกจาก Library
  void removeNovelFromLibrary(Map<String, dynamic> novelData) async {
    final loginState = Provider.of<LoginState>(context, listen: false);
    if (loginState.userLogin == false) {
      _showWarningDialog(context);
      return;
    }
    final userId = userData?['user_id'];
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาล็อกอินเพื่อใช้งาน ชั้นหนังสือ")),
      );
      return;
    }
    final response = await http.post(
      Uri.parse('${CallAPI.hostURL}/removeFromLibrary'),
      body: jsonEncode({
        'user_id': userId,
        'novel_id': novelData['novel_id'],
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('ลบ ${novelData['title']} ออกจากชั้นเรียบร้อยแล้ว')),
      );
      setState(() {
        isAddedToLibrary = false; // อัพเดตสถานะนิยายไม่อยู่ใน Library
      });
    }
  }

  // อัพเดทยอดวิวของนิยายที่ user เข้าไปกดอ่าน
  Future<bool> _updateViews(Map<String, dynamic> novelData) async {
    try {
      final response = await http.post(
        Uri.parse('${CallAPI.hostURL}/updateViews'),
        body: jsonEncode({'novel_id': novelData['novel_id']}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true; // อัพเดตยอดวิวสำเร็จ
      } else {
        return false; // การตอบกลับไม่ใช่ 200
      }
    } catch (e) {
      print('Error updating views: $e');
      return false; // จัดการข้อผิดพลาด
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            // ส่งค่า 'reload' กลับไปก่อน
            Navigator.pop(context, 'reload');
            // ย้อนกลับไปยังหน้าแรก
            Navigator.popUntil(
              context,
              (route) => route.isCurrent,
            );
          },
        ),
        title: Container(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.13,
          ),
          alignment: Alignment.center,
          // margin:
          //     EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.12),
          child: Text(
            widget.novelData['title'],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: widget.novelData['cover_image_bytes'] != null &&
                        widget.novelData['cover_image_bytes'].isNotEmpty
                    ? Image.memory(
                        widget.novelData['cover_image_bytes'],
                        width: MediaQuery.of(context).size.width * 0.375,
                        height: MediaQuery.of(context).size.height * 0.275,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/cover/novel1.jpg',
                        width: MediaQuery.of(context).size.width * 0.375,
                        height: MediaQuery.of(context).size.height * 0.275,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              Column(
                children: [
                  Text(
                    widget.novelData['title'],
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.0010,
                      right: MediaQuery.of(context).size.width * 0.0010,
                    ),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.012,
                      left: MediaQuery.of(context).size.width * 0.08,
                      right: MediaQuery.of(context).size.width * 0.08,
                    ),
                    height: MediaQuery.of(context).size.height * 0.09,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.cyan.shade100, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.cyan.shade50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              //ตรวจสอบค่าที่รับมาว่าเป็น String หรือ int ก่อนแล้วค่อยทำการแปลงค่า
                              formatViews(widget.novelData['views'] is String
                                  ? int.parse(widget.novelData['views'])
                                  : widget.novelData['views']),

                              // '${widget.novelData['views']}',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'ยอยวิว',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.020,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${widget.novelData['episode_count'] ?? '0'}',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'ตอน',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.020,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${widget.novelData['review_count']}',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'ความเห็น',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.020,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              Text(
                'บทนำ',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.020,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              Text(
                widget.novelData['description'],
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009,
              ),
              Row(
                children: [
                  Text(
                    //'by ${widget.novelData['username']} (UserID: ${userData?['user_id']})(NovelID: ${widget.novelData['novel_id']})',
                    'ผู้แต่ง',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.020,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${widget.novelData['username']}',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.020,
                      color: Colors.cyan[800], // กำหนดสีตามที่ต้องการ
                      fontWeight: FontWeight.bold, // ทำให้ข้อความเป็นตัวหนา
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009,
              ),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              Row(
                children: [
                  Text(
                    'ประเภทนิยาย',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.020,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${widget.novelData['tags']}',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.020,
                      // color: Colors.cyan[800], // กำหนดสีตามที่ต้องการ
                      // fontWeight: FontWeight.bold, // ทำให้ข้อความเป็นตัวหนา
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'คะแนนรีวิว',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.020,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Spacer(),

                  Row(
                    // สร้าง List  ที่มีความยาว 5 เพื่อแสดงดาวทั้งหมด 5 ดวง
                    // index จะเริ่มจาก 0 ถึง 4
                    children: List.generate(5, (index) {
                      // ตรวจสอบว่าค่า 'average_rating' เป็น String และแปลงเป็น double ถ้าใช่
                      double rating = double.tryParse(
                              widget.novelData['average_rating'].toString()) ??
                          0.0;
                      // ใช้ .floor() เพื่อตัดทศนิยมและแสดงดาวเต็มดวงในช่วงของ index 0 ถึง 4
                      // เช่นถ้า rating เป็น 3.5 จะแสดงดาวเต็มดวงในช่วง 0 ถึง 2
                      if (index < rating.floor()) {
                        return Icon(
                          Icons.star,
                          size: MediaQuery.of(context).size.height * 0.020,
                          color: Colors.cyan[800],
                        );
                        // ใช้สำหรับแสดงดาวครึ่งดวงในตำแหน่งที่ index ตรงกับค่าที่เหลือจากการตัดทศนิยม
                        // เช่นถ้า rating เป็น 3.5 จะแสดงดาวครึ่งดวงในตำแหน่งที่ 3
                      } else if (index < rating) {
                        return Icon(
                          Icons.star_half,
                          size: MediaQuery.of(context).size.height * 0.020,
                          color: Colors.cyan[800],
                        );
                        // ใช้สำหรับแสดงดาวว่างในตำแหน่งที่เกินจาก rating
                        // เช่นถ้า rating เป็น 3.5 จะแสดงดาวว่างในตำแหน่งที่ 4
                      } else {
                        return Icon(
                          Icons.star_border,
                          size: MediaQuery.of(context).size.height * 0.020,
                          color: Colors.cyan[800],
                        );
                      }
                    }),
                  ),
                  SizedBox(width: 5),
                  // แสดงค่าคะแนนเฉลี่ยแบบทศนิยม 1 ตำแหน่ง
                  Text(
                    '(${widget.novelData['average_rating'] != null ? (double.tryParse(widget.novelData['average_rating'].toString())?.toStringAsFixed(1) ?? '0.0') : '0.0'})',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.020,
                      // color: Colors.cyan[800], // กำหนดสีตามที่ต้องการ
                      // fontWeight: FontWeight.bold, // ทำให้ข้อความเป็นตัวหนา
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.020,
              ),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.020,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.cyan[50],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () async {
                // ตรวจสอบการล็อกอินก่อนดำเนินการต่อ
                if (userData!['user_id'] != null) {
                  // อัพเดตยอดวิวเมื่อกดปุ่มอ่าน
                  final success = await _updateViews(widget.novelData);

                  if (success) {
                    // ดึงข้อมูลตอนแรกของนิยายจาก API
                    final episodeResponse = await http.get(
                      Uri.parse(
                          '${CallAPI.hostURL}/firstepisode?novel_id=${widget.novelData['novel_id']}'),
                    );

                    if (episodeResponse.statusCode == 200) {
                      final episodeData = jsonDecode(episodeResponse.body);

                      // นำไปหน้าแสดง Content ของนิยาย novel_content_ui.dart พร้อมส่งข้อมูล episodeData  และตรวจสอบค่าที่ส่งกลับ
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NovelContentUi(
                                    novelData: widget.novelData,
                                    userData: userData!,
                                    episodeData:
                                        episodeData, // ส่งข้อมูลตอนแรกไป
                                  ))).then((_) {
                        reloadNovelData();
                      });
                    } else {
                      // ถ้าดึงตอนแรกไม่สำเร็จ ให้แสดงข้อความแจ้งเตือน
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ไม่สามารถดึงข้อมูลตอนแรกได้')),
                      );
                    }
                  } else {
                    // หากการอัปเดตยอดวิวล้มเหลว ให้แสดงข้อความแจ้งเตือน
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ไม่สามารถอัปเดตยอดวิวได้')),
                    );
                  }
                } else {
                  // หากยังไม่ได้ล็อกอิน ให้แสดงข้อความแจ้งเตือน
                  _showWarningDialog(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.cyan[800],
                elevation: 0,
                fixedSize: Size(
                  MediaQuery.of(context).size.width * 0.40,
                  MediaQuery.of(context).size.height * 0.06,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.circular(10.0),
                ),
              ),
              child: Text(
                'อ่าน',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  color: Colors.cyan[800],
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     showGeneralDialog(
            //       context: context,
            //       barrierLabel: "Index",
            //       barrierDismissible: true,
            //       barrierColor: Colors.black.withOpacity(0.5),
            //       transitionDuration: const Duration(milliseconds: 200),
            //       pageBuilder: (context, anim1, anim2) {
            //         return Align(
            //           alignment: Alignment.bottomCenter,
            //           child: SizedBox(
            //             height: MediaQuery.of(context).size.height * 0.55,
            //             child: _buildNovelIndexSheet(),
            //           ),
            //         );
            //       },
            //       transitionBuilder: (context, anim1, anim2, child) {
            //         return SlideTransition(
            //           position: Tween(
            //             begin: const Offset(0, 1),
            //             end: const Offset(0, 0),
            //           ).animate(anim1),
            //           child: child,
            //         );
            //       },
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.white, // ตั้งค่าสีพื้นหลังเป็นขาว
            //     foregroundColor:
            //         Colors.cyan[800], // ตั้งค่าสีข้อความเป็น cyan 800
            //     elevation: 0,
            //     fixedSize: Size(
            //       MediaQuery.of(context).size.width * 0.29,
            //       MediaQuery.of(context).size.height * 0.06,
            //     ),

            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadiusDirectional.circular(
            //         10.0,
            //       ), // กำหนดให้ขอบเป็นสี่เหลี่ยม
            //     ), // ลบเงาใต้ปุ่มออก เพื่อดูเรียบง่ายขึ้น
            //   ),
            //   child: Text(
            //     'สารบัญ',
            //     style: TextStyle(
            //       fontSize: MediaQuery.of(context).size.height * 0.019,
            //       color: Colors.cyan[800],
            //     ), // สีข้อความสามารถตั้งได้ทั้งในนี้และใน foregroundColor
            //   ),
            // ),
            ElevatedButton(
              onPressed: () {
                if (isAddedToLibrary == true) {
                  // addNovelToLibrary(widget.novelData);
                  removeNovelFromLibrary(widget.novelData);
                } else {
                  // removeNovelFromLibrary(widget.novelData);
                  addNovelToLibrary(widget.novelData);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAddedToLibrary
                    ? Colors.cyan[800]
                    : Colors.white, // สีของปุ่ม
                foregroundColor: isAddedToLibrary
                    ? Colors.white
                    : Colors.cyan[800], // สีข้อความ
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.circular(
                    10.0,
                  ),
                  // กำหนดให้ขอบเป็นสี่เหลี่ยมมน
                ),
                fixedSize: Size(
                  MediaQuery.of(context).size.width * 0.40,
                  MediaQuery.of(context).size.height * 0.06,
                ),
              ),
              child: Text(
                isAddedToLibrary ? 'ลบออกจากชั้น' : 'เพิ่มเข้าชั้น',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        // ),
      ),
    );
  }

  Widget _buildNovelIndexSheet() {
    return NovelIndexUi(
      novelData: widget.novelData,
      userData: userData!,
    );
  }
}
