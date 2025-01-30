// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:fitstindex_mobileapp/novelviews/novel_content_ui.dart';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class NovelIndexUi extends StatefulWidget {
  // สร้างตัวแปรสําหรับเก็บข้อมูลนิยาย ที่ส่งมาจาก NovelInfoUi
  final Map<String, dynamic> novelData;
  // สร้างตัวแปรสําหรับเก็บข้อมูลผู้ใช้ ที่ส่งมาจาก NovelInfoUi
  final Map<String, dynamic> userData;
  const NovelIndexUi(
      {super.key, required this.novelData, required this.userData});

  @override
  State<NovelIndexUi> createState() => _NovelIndexUiState();
}

class _NovelIndexUiState extends State<NovelIndexUi> {
  List<dynamic> episodes = []; // เก็บข้อมูลตอนทั้งหมดของนิยาย
  @override
  void initState() {
    super.initState();
    fetchEpisodes(); // เรียกฟังก์ชันเมื่อหน้าโหลด
  }

  Future<void> fetchEpisodes() async {
    final novelId =
        widget.novelData['novel_id']; // ใช้ novel_id จากข้อมูลที่รับมา
    try {
      final response = await http.get(
        Uri.parse(
            '${CallAPI.hostURL}/episodes?novel_id=$novelId'), // API สำหรับดึงข้อมูลตอนทั้งหมด
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            episodes = data;
          });
        } else {
          print('No episodes found');
        }
      } else {
        print('Failed to load episodes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        episodes = [];
      });
      print('Error fetching episodes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.010,
              ),
              child: Text(
                'สารบัญ',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[800]),
              ),
            ),
            Divider(
              color: Colors.cyan,
            ),
          ],
        ),
      ),
      body: episodes.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // แสดง progress ขณะรอดึงข้อมูล
          : ListView.builder(
              padding: EdgeInsets.only(
                // top: MediaQuery.of(context).size.height * 0.020,
                left: MediaQuery.of(context).size.width * 0.030,
                right: MediaQuery.of(context).size.width * 0.030,
              ),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.013,
                    ),
                    GestureDetector(
                      onTap: () {
                        //ปิดหน้าปัจบัน
                        Navigator.pop(context);
                        // กดแล้วแสดงเนื้อหาตอน
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NovelContentUi(
                              novelData: widget.novelData,
                              userData: widget.userData,
                              episodeData: episode, // ส่งค่า episodeData
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'ตอนที่ ${episode['episode_number']} : ${episode['title']}',
                        style: TextStyle(fontSize: 18, color: Colors.cyan[800]),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.013,
                    ),
                    Divider(),
                  ],
                );
              },
            ),
    );
  }
}
