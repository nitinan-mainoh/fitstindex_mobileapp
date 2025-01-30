import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NovelCommentUi extends StatefulWidget {
  // สร้างตัวแปร novelData เพื่อรับข้อมูลนิยายที่ส่งมาจาก
  final Map<String, dynamic> novelData;
  const NovelCommentUi({super.key, required this.novelData});

  @override
  State<NovelCommentUi> createState() => _NovelCommentUiState();
}

class _NovelCommentUiState extends State<NovelCommentUi> {
  Map<String, dynamic>? userData;
  final _commentController = TextEditingController();
  double _rating = 1.0; // ค่าเริ่มต้นของคะแนน
  late Future<List<Map<String, dynamic>>> comment;
  bool _isCommentButton = false;

  Future<void> loadUserData() async {
    final data = await fetchUserData(context);
    if (data != null && mounted) {
      setState(() {
        userData = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    comment = fetchComments(); // เรียกใช้ฟังก์ชันเพื่อดึงความคิดเห็นตอนเริ่มต้น
    _commentController
        .addListener(_checkIfTextIsEmpty); // ฟังการเปลี่ยนแปลงของ TextField
  }

  @override
  void dispose() {
    _commentController.removeListener(_checkIfTextIsEmpty);
    _commentController.dispose();
    super.dispose();
  }

  void _checkIfTextIsEmpty() {
    setState(() {
      _isCommentButton = _commentController.text.isNotEmpty;
    });
  }

  Future<List<Map<String, dynamic>>> fetchComments() async {
    final novelId = widget.novelData['novel_id']; // ใช้ novel_id จาก novelData
    try {
      final response = await http.get(
        Uri.parse('${CallAPI.hostURL}/getComments?novel_id=$novelId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map((review) => {
                  'user_name': review['user_name'],
                  'review_text': review['review_text'],
                  'rating': review['rating'],
                })
            .toList();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _submitComment() async {
    final commentText = _commentController.text;
    final novelId = widget.novelData['novel_id']; // ใช้ novel_id จาก novelData
    final userId = userData?['user_id']; // รับ user_id จริงจากข้อมูล user

    try {
      final response = await http.post(
        Uri.parse('${CallAPI.hostURL}/addReview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'novel_id': novelId,
          'user_id': userId,
          'rating': _rating.toDouble(),
          'review_text': commentText,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกความคิดเห็นสำเร็จ')),
        );
        _commentController.clear();
        setState(() {
          comment = fetchComments(); // รีเฟรชความคิดเห็นหลังจากส่งสำเร็จ
          
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('บันทึกความคิดเห็นล้มเหลว: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'ความคิดเห็น',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.020,
            color: Colors.cyan[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: comment,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading comments'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No comments available'));
                } else {
                  final comments = snapshot.data!;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final double rating = (comment['rating'] is int)
                          ? (comment['rating'] as int).toDouble()
                          : comment['rating'] as double;

                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              comment['user_name'],
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.020,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan[800],
                              ),
                            ),
                            subtitle: Text(
                              comment['review_text'],
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018,
                                color: Colors.cyan,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    double rating = comment['rating'] != null
                                        ? (comment['rating'] is int
                                            ? (comment['rating'] as int)
                                                .toDouble()
                                            : comment['rating'])
                                        : 0.0;

                                    if (index < rating.floor()) {
                                      return Icon(
                                        Icons.star,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.020,
                                        color: Colors.cyan[800],
                                      );
                                    } else if (index < rating) {
                                      return Icon(
                                        Icons.star_half,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.020,
                                        color: Colors.cyan[800],
                                      );
                                    } else {
                                      return Icon(
                                        Icons.star_border,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.020,
                                        color: Colors.cyan[800],
                                      );
                                    }
                                  }),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  rating.toStringAsFixed(
                                      1), // แสดงคะแนนเป็นทศนิยม
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.018,
                                    color: Colors.cyan[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        'Rating: ${_rating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.020,
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: Colors.cyan,
                          inactiveTrackColor: Colors.cyan[100],
                          thumbColor: Colors.cyan,
                          overlayColor: Colors.cyan.withOpacity(0.2),
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 24.0),
                        ),
                        child: Slider(
                          value: _rating,
                          min: 1.0,
                          max: 5.0,
                          divisions: 8,
                          onChanged: (value) {
                            setState(() {
                              _rating = value;
                            });
                          },
                          label: _rating.toStringAsFixed(1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.020,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.022,
                        ),
                        decoration: InputDecoration(
                          hintText: 'พิมพ์ความคิดเห็น...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isCommentButton
                          ? () {
                              _submitComment();
                            }
                          : null, // ปิดใช้งานปุ่มหากไม่มีข้อความ
                      icon: Icon(
                        Icons.send,
                        color: _isCommentButton
                            ? Colors.cyan[800]
                            : Colors.grey, // เปลี่ยนสีตามสถานะปุ่ม
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
