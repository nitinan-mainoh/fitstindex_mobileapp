// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:typed_data';

import 'package:fitstindex_mobileapp/novelviews/novel_info_ui.dart';
import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  late Future<List<Map<String, dynamic>>> newNovelData;
  late Future<List<Map<String, dynamic>>> updatedNovelData;
  late Future<List<Map<String, dynamic>>> trendingNovelData;

  late StreamSubscription refreshListener;

  @override
  void initState() {
    super.initState();
    newNovelData = fetchNewNovels();
    updatedNovelData = fetchUpdatedNovels();
    trendingNovelData = fetchTrendingNovels();

    // ลงทะเบียนฟัง RefreshHomeEvent
    refreshListener = eventBus.on<RefreshHomeEvent>().listen((event) {
      setState(() {
        newNovelData = fetchNewNovels();
        updatedNovelData = fetchUpdatedNovels();
        trendingNovelData = fetchTrendingNovels();
      });
    });
  }

  @override
  void dispose() {
    refreshListener.cancel(); // ยกเลิก Listener
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchNewNovels() async {
    final response = await http.get(Uri.parse('${CallAPI.hostURL}/newnovel'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((novel) {
        Uint8List? imageBytes;
        if (novel['cover_image'] != null && novel['cover_image'].isNotEmpty) {
          try {
            imageBytes = base64Decode(novel['cover_image']);
          } catch (e) {
            print("Error decoding image: $e");
            imageBytes = null;
          }
        }
        return {
          'novel_id': novel['novel_id'],
          'title': novel['title'],
          'description': novel['description'],
          'cover_image_bytes': imageBytes,
          'author_id': novel['author_id'],
          'username': novel['username'],
          'tags': novel['tags'],
          'views': (novel['views'] ?? 0).toString(),
          'episode_count': (novel['episode_count'] ?? 0).toString(),
          'review_count': novel['review_count'].toString(),
          'average_rating': novel['average_rating'],
          'created_at': novel['created_at']
        };
      }).toList();
    } else {
      throw Exception('Failed to load novels');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUpdatedNovels() async {
    final response = await http.get(
      Uri.parse('${CallAPI.hostURL}/updatednovels'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((novel) {
        Uint8List? imageBytes;
        if (novel['cover_image'] != null && novel['cover_image'].isNotEmpty) {
          try {
            imageBytes = base64Decode(novel['cover_image']);
          } catch (e) {
            print("Error decoding image: $e");
            imageBytes = null;
          }
        }
        return {
          'novel_id': novel['novel_id'],
          'title': novel['title'],
          'description': novel['description'],
          'cover_image_bytes': imageBytes,
          'author_id': novel['author_id'],
          'username': novel['username'],
          'tags': novel['tags'],
          'views': (novel['views'] ?? 0).toString(),
          'episode_count': (novel['episode_count'] ?? 0).toString(),
          'review_count': novel['review_count'].toString(),
          'average_rating': novel['average_rating'],
          'updated_at': novel['updated_at']
        };
      }).toList();
    } else {
      throw Exception('Failed to load novels');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrendingNovels() async {
    final response = await http.get(
      Uri.parse('${CallAPI.hostURL}/trendingnovels'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((novel) {
        Uint8List? imageBytes;
        if (novel['cover_image'] != null && novel['cover_image'].isNotEmpty) {
          try {
            imageBytes = base64Decode(novel['cover_image']);
          } catch (e) {
            print("Error decoding image: $e");
            imageBytes = null;
          }
        }
        return {
          'novel_id': novel['novel_id'],
          'title': novel['title'],
          'description': novel['description'],
          'cover_image_bytes': imageBytes,
          'author_id': novel['author_id'],
          'username': novel['username'],
          'tags': novel['tags'],
          'views': (novel['views'] ?? 0).toString(),
          'episode_count': (novel['episode_count'] ?? 0).toString(),
          'review_count': novel['review_count'].toString(),
          'average_rating': novel['average_rating'],
          'created_at': novel['created_at']
        };
      }).toList();
    } else {
      throw Exception('Failed to load novels');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("นิยายเรื่องใหม่", context),
              _novelListSection(newNovelData),
              _sectionTitle("นิยายอัพเดทตอนใหม่", context),
              _novelListSection(updatedNovelData),
              _sectionTitle("นิยายเทรนดิ้ง", context),
              _novelListSection(trendingNovelData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.010,
        left: MediaQuery.of(context).size.width * 0.025,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.022,
          color: Colors.cyan[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _novelListSection(Future<List<Map<String, dynamic>>> novelData) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.375,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: novelData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.cyan[800],
            ));
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Failed to load data. Tap to retry."),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available."));
          } else {
            final novels = snapshot.data!;
            return ListView.builder(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: novels.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NovelInfoUi(
                          novelData: novels[index],
                        ),
                      ),
                    );
                  },
                  child: _buildNovelCard(novels[index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildNovelCard(Map<String, dynamic> novel) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.375,
            height: MediaQuery.of(context).size.height * 0.275,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow()],
            ),
            child: novel['cover_image_bytes'] != null &&
                    novel['cover_image_bytes'].isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      fit: BoxFit.cover,
                      novel['cover_image_bytes'],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/images/cover/novel1.jpg',
                        fit: BoxFit.cover),
                  ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.375,
            child: Text(
              novel['title'],
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            ' ${novel['tags']}',
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey[600],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.remove_red_eye_rounded,
                color: Colors.grey[600],
                size: MediaQuery.of(context).size.height * 0.018,
              ),
              Text(
                ' ${novel['views']}',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.015,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              Icon(
                Icons.view_list_rounded,
                color: Colors.grey[600],
                size: MediaQuery.of(context).size.height * 0.018,
              ),
              Text(
                ' ${novel['episode_count'] ?? '0'}',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.015,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
