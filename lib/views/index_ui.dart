// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:fitstindex_mobileapp/sharedata.dart';
import 'package:fitstindex_mobileapp/userviews/user_info_ui.dart';
import 'package:fitstindex_mobileapp/views/appviews/home_ui.dart';
import 'package:fitstindex_mobileapp/views/appviews/library_ui.dart';
import 'package:fitstindex_mobileapp/views/appviews/search_ui.dart';
import 'package:fitstindex_mobileapp/views/appviews/user_login_ui.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';

class IndexUi extends StatefulWidget {
  final int pageSelected; // เพิ่มตัวแปรสำหรับเก็บหน้าเริ่มต้น

  const IndexUi({super.key, this.pageSelected = 0}); // กำหนดค่าเริ่มต้นเป็น 0

  @override
  State<IndexUi> createState() => _IndexUiState();
}

class _IndexUiState extends State<IndexUi> {
  // สร้างตัวแปร userData สําหรับเก็บข้อมูลผู้ใช้โดยค่าเริ่มต้นเป็น null ได้
  Map<String, dynamic>? userData;
  // ฟังก์ชั่นสําหรับดึงข้อมูลผู้ใช้
  Future<void> loadUserData() async {
    // ดึงข้อมูลผู้ใช้จาก SharedPreferences จาก ShareData
    final data = await fetchUserData(context);
    // ตรวจสอบข้อมูลผู้ใช้ถ้ามีข้อมูล
    if (data != null && mounted) {
      setState(() {
        // นำข้อมูลผู้ใช้ไปยังตัวแปร userData
        userData = data;
      });
    }
  }

//สร้างตัวแปรสำหรับเก็บหน้าที่จะถูกเลือกให้แสดง
  late int _pageSelected;
//สร้างฟังก์ชั่นสําหรับเปลี่ยนหน้า
  List<Widget> pageList(bool userLogin) {
    return [
      HomeUi(),
      SearchUi(),
      LibraryUi(),
      UserInfoUi(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageSelected = widget.pageSelected; // ใช้ค่าที่ส่งมาจาก constructor
  }

// ฟังก์ชันแสดง Popup เมื่อต้องการเข้าถึง Library แต่ยังไม่ได้ล็อกอิน
  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'กรุณาล็อกอิน',
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
                'กรุณาล็อกอินเพื่อเข้าใช้งาน ชั้นหนังสือ',
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด Popup
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserLoginUi(),
                    ),
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
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
                    MediaQuery.of(context).size.width * 0.25,
                    MediaQuery.of(context).size.height * 0.06,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool userLogin = Provider.of<LoginState>(context).userLogin;
    loadUserData();
    return Scaffold(
      appBar: AppBar(
        //ป้องการไม่ให้แสดงปุ่มย้อนกลับเมื่อมีการใช้ push จากหน้าอื่นๆย้อนกลับมาที่ index_ui
        automaticallyImplyLeading: false,
        title: Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.025,
          ),
          child: Center(
            child: Text(
              'First Index',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.cyan[800],
              ),
            ),
          ),
        ),
      ),
      body: pageList(userLogin)[_pageSelected],
      bottomNavigationBar: SalomonBottomBar(
        onTap: (paramValue) {
          // ตรวจสอบว่าผู้ใช้กำลังจะเข้าถึง Library โดยไม่ล็อกอินหรือไม่
          if (paramValue == 2 && !userLogin) {
            _showLoginAlert(context);
          } else {
            setState(() {
              _pageSelected = paramValue;
            });
          }
        },
        currentIndex: _pageSelected,
        items: [
          SalomonBottomBarItem(
            icon: Icon(
              Icons.home,
            ),
            title: Text(
              'Home',
            ),
            unselectedColor: Colors.grey,
            selectedColor: Colors.cyan[800],
          ),
          SalomonBottomBarItem(
            icon: Icon(
              Icons.search,
            ),
            title: Text(
              'Search',
            ),
            unselectedColor: Colors.grey,
            selectedColor: Colors.cyan[800],
          ),
          SalomonBottomBarItem(
            icon: Icon(
              Icons.my_library_books_rounded,
            ),
            title: Text(
              'Library',
            ),
            unselectedColor: Colors.grey,
            selectedColor: Colors.cyan[800],
          ),
          SalomonBottomBarItem(
            icon: Icon(
              Icons.account_box_rounded,
            ),
            title: Text(
              'User',
            ),
            unselectedColor: Colors.grey,
            selectedColor: Colors.cyan[800],
          ),
        ],
      ),
    );
  }
}
