import 'dart:convert';
import 'dart:typed_data';
import 'package:fitstindex_mobileapp/novelviews/novel_info_ui.dart';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LibraryUi extends StatefulWidget {
  const LibraryUi({super.key});

  @override
  State<LibraryUi> createState() => _LibraryUiState();
}

class _LibraryUiState extends State<LibraryUi> {
  // สร้างตัวแปรสําหรับเก็บข้อมูลผู้ใช้ ในรูปแบบ Map
  Map<String, dynamic>? userData;
  // สร้างตัวแปรสําหรับเก็บข้อมูลหนังสือในรูปแบบ List
  Future<List<Map<String, dynamic>>>? libraryData;
  List<Map<String, dynamic>> novelImageCover = [];

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
        // ดึงข้อมูลชั้นหนังสือของ user จาก API มาเก็บใน libraryData ในรูปแบบ List
        libraryData = fetchLibraryNovels();
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchLibraryNovels() async {
    if (userData == null || userData!['user_id'] == null) {
      throw Exception('User ID not found');
    }

    final response = await http.get(
      Uri.parse('${CallAPI.hostURL}/library?user_id=${userData!['user_id']}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // แปลงข้อมูล Base64 เป็น Uint8List สำหรับแต่ละรายการในลิสต์
      return data.map<Map<String, dynamic>>((novel) {
        Uint8List? imageBytes;
        if (novel['cover_image'] != null && novel['cover_image'].isNotEmpty) {
          try {
            imageBytes = base64Decode(novel['cover_image']);
          } catch (e) {
            print("Error decoding Base64 image: $e");
            imageBytes = null;
          }
        }
        return {
          ...novel,
          'cover_image_bytes':
              imageBytes, // เพิ่มฟิลด์ใหม่สำหรับรูปภาพที่แปลงแล้ว
        };
      }).toList();
    } else {
      throw Exception('Failed to load library novels');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: libraryData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to load data."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No novels in your library."));
          } else {
            final novels = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.025,
                ),
                // alignment: Alignment.center,
                child: Wrap(
                  spacing: 11.0, // ระยะห่างระหว่างไอเท็มในแนวนอน
                  runSpacing: 20.0, // ระยะห่างระหว่างไอเท็มในแนวตั้ง
                  children: List.generate(novels.length, (index) {
                    final novel = novels[index];
                    return GestureDetector(
                      onTap: () async {
                        // กดเข้า novel_info_ui และรอผลลัพธ์กลับมา
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NovelInfoUi(novelData: novel),
                          ),
                        );
                        // ถ้าผลลัพธ์กลับมาจาก NovelInfoUi และเป็นการ reload หน้า
                        if (result == 'reload') {
                          loadUserData(); // โหลดข้อมูลใหม่
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.3, // ปรับขนาดไอเท็ม
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // รูปภาพนิยาย
                            Container(
                              width: MediaQuery.of(context).size.width * 0.30,
                              height: MediaQuery.of(context).size.height * 0.21,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: novel['cover_image_bytes'] != null
                                      ? MemoryImage(novel['cover_image_bytes']!)
                                      : AssetImage(
                                              'assets/images/cover/novel1.jpg')
                                          as ImageProvider,
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.002,
                            ),
                            // ชื่อเรื่อง
                            Text(
                              novel['title'],
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.015,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),

                            // ผู้แต่ง
                            Text(
                              'by ${novel['username']}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
