// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:fitstindex_mobileapp/novelviews/novel_info_ui.dart';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class SearchUi extends StatefulWidget {
  const SearchUi({super.key});

  @override
  State<SearchUi> createState() => _SearchUiState();
}

class _SearchUiState extends State<SearchUi> {
  late Future<List<Map<String, dynamic>>> tagAllSelected;
  List<Map<String, dynamic>> searchResults = [];
  List<String> selectedTags = [''];
  bool isSelected = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    selectedTags = ['']; // กำหนดค่าเริ่มต้นให้ "ทั้งหมด" ถูกเลือก
  }

  Future<void> searchNovels(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      final uri = Uri.parse('${CallAPI.hostURL}/getNovelsByTag')
          .replace(queryParameters: {
        'getTitle': query,
        'tags': selectedTags.join(","),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // แปลงข้อมูล Base64 เป็น Uint8List สำหรับแต่ละรายการในลิสต์
        setState(() {
          searchResults = data.map<Map<String, dynamic>>((novel) {
            Uint8List? imageBytes;
            if (novel['cover_image'] != null &&
                novel['cover_image'].isNotEmpty) {
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
        });
      } else {
        setState(() {
          searchResults = [];
        });
      }
    } catch (e) {
      setState(() {
        searchResults = [];
      });
    }
  }

  //ใช้ library dart:async สำหรับเรียกใช้งาน _debounce
  //หน่วงเวลาการ Query เพื่อลดกด Query ตลอดเวลาที่ค่าการค้นหามีการเปลี่ยนแปลง
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      //หน่วงเวลาเสร็จแล้วส่งค่าไปที่ searchNovels เพื่อ Query
      searchNovels(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.005,
            left: MediaQuery.of(context).size.width * 0.025,
            right: MediaQuery.of(context).size.width * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text(
                'ค้นหานิยาย',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  color: Colors.cyan[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: _onSearchChanged,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        color: Colors.cyan[800],
                      ),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.cyan, width: 3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.cyan, width: 3),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: MediaQuery.of(context).size.height * 0.030,
                          color: Colors.cyan[800],
                        ),
                        hintText: "ค้นหา",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: Colors.cyan[800],
                      size: MediaQuery.of(context).size.height * 0.030,
                    ),
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierLabel: "Filter",
                        barrierDismissible: true,
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, anim1, anim2) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: _buildTagFilterSheet(),
                            ),
                          );
                        },
                        transitionBuilder: (context, anim1, anim2, child) {
                          return SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 1),
                              end: const Offset(0, 0),
                            ).animate(anim1),
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.020),
              searchResults.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final novel = searchResults[index];
                        return SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.20, // ปรับความสูงของแต่ละแถว
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  // นำทางไปยังหน้า novel_info_ui พร้อมส่งข้อมูล novelData
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NovelInfoUi(novelData: novel),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.28,
                                  height:
                                      MediaQuery.of(context).size.height * 0.19,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: novel['cover_image_bytes'] != null
                                        ? Image.memory(
                                            novel[
                                                'cover_image_bytes'], // ใช้รูปภาพที่แปลงแล้ว
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/images/cover/novel1.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10.0), // ระยะห่างระหว่างรูปภาพกับข้อความ
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        novel['title'],
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.020,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.cyan[800],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${novel['username']}',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.017, // เพิ่มขนาดตัวอักษรคำอธิบาย
                                          color: Colors.cyan,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${novel['tags']}',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.017, // เพิ่มขนาดตัวอักษรคำอธิบาย
                                          color: Colors.cyan,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                      Text(
                                        '${novel['description']}',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.017, // เพิ่มขนาดตัวอักษรคำอธิบาย
                                          color: Colors.cyan[800],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye_rounded,
                                            color: Colors.cyan,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.018,
                                          ),
                                          Text(
                                            //ตรวจสอบค่าที่รับมาว่าเป็น String หรือ int ก่อนแล้วค่อยทำการแปลงค่า
                                            ' ${formatViews(novel['views'] is String ? double.parse(novel['views']) : novel['views'])}',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015, // เพิ่มขนาดตัวอักษรคำอธิบาย
                                              color: Colors.cyan,
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                          ),
                                          Icon(
                                            Icons.view_list_rounded,
                                            color: Colors.cyan,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.018,
                                          ),
                                          Text(
                                            ' ${novel['episode_count']}',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015, // เพิ่มขนาดตัวอักษรคำอธิบาย
                                              color: Colors.cyan,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Text(
                      'ไม่มีผลลัพธ์ที่ตรงกับการค้นหา',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagFilterSheet() {
    return Scaffold(
      body: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.015,
                left: MediaQuery.of(context).size.width * 0.035,
                right: MediaQuery.of(context).size.width * 0.035,
              ),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.010,
                      bottom: MediaQuery.of(context).size.height * 0.015,
                    ),
                    child: Text(
                      textAlign: TextAlign.start,
                      "หมวดหมู่ประเภทนิยาย",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        color: Colors.cyan[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: [
                      _buildFilterButton("ทั้งหมด", setSheetState),
                      _buildFilterButton("ผจญภัย", setSheetState),
                      _buildFilterButton("แฟนตาซี", setSheetState),
                      _buildFilterButton("วิทยาศาสตร์", setSheetState),
                      _buildFilterButton("โรแมนติก", setSheetState),
                      _buildFilterButton("สยองขวัญ", setSheetState),
                      _buildFilterButton("ลึกลับ", setSheetState),
                      _buildFilterButton("กำลังภายใน", setSheetState),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  //setState เมื่อกดปุ่มแล้วสีไม่เปลี่ยนตามต้อปปิดและเปิดหน้าใหม่เพื่อ refresh สถานะเสมอ
  //จึงใช้ setSheetState แทนโดยที่จะทำการ refresh sheet ทุกครั้งที่มีการกดปุ่มเลือกประเภทนิยาย
  Widget _buildFilterButton(String category, StateSetter setSheetState) {
    bool isSelected = category == 'ทั้งหมด'
        ? selectedTags.contains('')
        : selectedTags.contains(category);

    return ElevatedButton(
      onPressed: () {
        setSheetState(() {
          bool isAllButton = category == 'ทั้งหมด';
          if (isAllButton) {
            selectedTags = [''];
          } else {
            if (selectedTags.contains('ทั้งหมด') || selectedTags.contains('')) {
              selectedTags.remove('ทั้งหมด');
              selectedTags.remove('');
            }
            if (selectedTags.contains(category)) {
              selectedTags.remove(category);
            } else {
              if (selectedTags.length < 2) {
                selectedTags.add(category);
              }
            }
            if (selectedTags.isEmpty) {
              selectedTags = [''];
            }
          }
          searchNovels(''); // เรียกการค้นหาใหม่
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.cyan[700] : Colors.white,
        shadowColor: Colors.black,
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.cyan[800]!,
          width: 2,
        ),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.020,
          color: isSelected ? Colors.white : Colors.cyan[800],
        ),
      ),
    );
  }
}
