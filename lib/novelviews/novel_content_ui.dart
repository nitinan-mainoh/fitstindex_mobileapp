import 'dart:convert';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fitstindex_mobileapp/novelviews/novel_comment_ui.dart';
import 'package:fitstindex_mobileapp/novelviews/novel_index_ui.dart';
import 'package:flutter/material.dart';

class NovelContentUi extends StatefulWidget {
  // ตัวแปรที่ใช้รับข้อมูลจาก novelData novel_info_ui.dart
  final Map<String, dynamic> novelData;
  // ตัวแปรที่ใช้รับข้อมูล userData จาก novel_info_ui.dart
  final Map<String, dynamic> userData;
  // ตัวแปรที่ใช้รับข้อมูล episodeData จาก novel_info_ui.dart
  final Map<String, dynamic> episodeData;
  const NovelContentUi({
    super.key,
    required this.novelData, // รับข้อมูล novelData จากหน้าอื่น
    required this.userData, // รับข้อมูล userData จากหน้าอื่น
    required this.episodeData, // รับข้อมูล episodeData จากหน้าอื่น
  });

  @override
  State<NovelContentUi> createState() => _NovelContentUiState();
}

class _NovelContentUiState extends State<NovelContentUi> {
  // สร้างตัวแปรสำรับค่าที่ใช้ในการสลับการแสดงผลของ AppBar และ BottomAppBar
  bool _showAppBar = true;
  bool _showBottomBar = true;

  // ฟังก์ชันที่ใช้ในการสลับการแสดงผลของ AppBar และ BottomAppBar

  void _toggleBars() {
    setState(() {
      _showAppBar = !_showAppBar;
      _showBottomBar = !_showBottomBar;
    });
  }

  Future<String> fetchEpisodeContent(int episodeId) async {
    final response = await http.get(
      Uri.parse('${CallAPI.hostURL}/getEpisodeContent?episode_id=$episodeId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['content']; // ดึงเฉพาะเนื้อหาของตอน
    } else {
      throw Exception('Failed to load episode content');
    }
  }

  // ฟังก์ชันสำหรับสร้าง NovelIndexSheet
  Widget _buildNovelIndexSheet(BuildContext context) {
    return NovelIndexUi(novelData: widget.novelData, userData: widget.userData);
  }

  // ฟังก์ชันสำหรับสร้าง NovelCommentSheet
  Widget _buildNovelCommentSheet(BuildContext context) {
    return NovelCommentUi(novelData: widget.novelData);
  }

  // ฟังก์ชันดึงข้อมูลตอนก่อนหน้า
  Future<void> _fetchPreviousEpisode() async {
    final currentEpisodeNumber = widget.episodeData['episode_number'];
    final novelId = widget.novelData['novel_id'];

    final response = await http.get(
      Uri.parse(
          '${CallAPI.hostURL}/previousepisode?novel_id=$novelId&episode_number=$currentEpisodeNumber'),
    );

    if (response.statusCode == 200) {
      final previousEpisode = jsonDecode(response.body);
      if (previousEpisode != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NovelContentUi(
              novelData: widget.novelData,
              userData: widget.userData,
              episodeData: previousEpisode,
            ),
          ),
        );
      }
    } else {
      throw Exception('Failed to load previous episode');
    }
  }

  // ฟังก์ชันดึงข้อมูลตอนถัดไป
  Future<void> _fetchNextEpisode() async {
    final currentEpisodeNumber = widget.episodeData['episode_number'];
    final novelId = widget.novelData['novel_id'];

    final response = await http.get(
      Uri.parse(
          '${CallAPI.hostURL}/nextepisode?novel_id=$novelId&episode_number=$currentEpisodeNumber'),
    );

    if (response.statusCode == 200) {
      final nextEpisode = jsonDecode(response.body);
      if (nextEpisode != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NovelContentUi(
              novelData: widget.novelData,
              userData: widget.userData,
              episodeData: nextEpisode,
            ),
          ),
        );
      }
    } else {
      throw Exception('Failed to load next episode');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลตอนปัจจุบัน จาก episodeData ที่รับมาจากการเลือกตอนที่หน้าอื่น
    final currentEpisodeNumber = widget.episodeData['episode_number'];
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.cyan[50],
              leading: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.cyan[800],
                ),
                onPressed: () {
                  // ส่ง Event เพื่อรีโหลดหน้า HomeUi
                  eventBus.fire(RefreshHomeEvent());
                  // ปิดหน้านี้และกลับไปที่ NovelInfoUi
                  Navigator.pop(context, 'reload');
                },
              ),
              title: Text(
                'ตอนที่ ${widget.episodeData['episode_number']} ${widget.episodeData['title']}',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                  color: Colors.cyan[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: GestureDetector(
        onTap: _toggleBars, // เรียกใช้งานฟังก์ชันเมื่อแตะที่หน้าจอ
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  '${widget.episodeData['content']}',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.020,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _showBottomBar
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierLabel: "Index",
                        barrierDismissible: true,
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (context, anim1, anim2) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: _buildNovelIndexSheet(context),
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
                    icon: Icon(
                      FontAwesomeIcons.list,
                      size: MediaQuery.of(context).size.height * 0.03,
                      color: Colors.cyan[800],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierLabel: "Comment",
                        transitionDuration: const Duration(milliseconds: 250),
                        pageBuilder: (context, anim1, anim2) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: _buildNovelCommentSheet(context),
                            ),
                          );
                        },
                        transitionBuilder: (context, anim1, anim2, child) {
                          return SlideTransition(
                            position: Tween(
                              begin: const Offset(1, 0),
                              end: const Offset(0, 0),
                            ).animate(anim1),
                            child: child,
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.mode_comment_rounded,
                      size: MediaQuery.of(context).size.height * 0.030,
                      color: Colors.cyan[800],
                    ),
                  ),
                  IconButton(
                    // ปุ่มเลือก episode ก่อนหน้า
                    onPressed: currentEpisodeNumber > 1
                        ? _fetchPreviousEpisode
                        : null, // กดได้เฉพาะเมื่อเป็นตอนที่มากกว่า 1
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: MediaQuery.of(context).size.height * 0.03,
                      color: currentEpisodeNumber > 1
                          ? Colors.cyan[800]
                          : Colors.grey, // สีเทาหากไม่สามารถกดได้
                    ),
                  ),
                  IconButton(
                    // ปุ่มเลือก episode ถัดไป
                    //int.parse() เพื่อแปลงค่าประเภท String ให้เป็น int ก่อนการเปรียบเทียบ
                    onPressed: int.parse(widget.episodeData['episode_number']
                                .toString()) <
                            int.parse(
                                widget.novelData['episode_count'].toString())
                        ? _fetchNextEpisode
                        : null, // กดได้ถ้าไม่ใช่ตอนสุดท้าย
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: MediaQuery.of(context).size.height * 0.03,
                      color: int.parse(widget.episodeData['episode_number']
                                  .toString()) <
                              int.parse(
                                  widget.novelData['episode_count'].toString())
                          ? Colors.cyan[800]
                          : Colors.grey, // สีเทาหากเป็นตอนสุดท้าย
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
