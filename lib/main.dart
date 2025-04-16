import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '복약 알림 앱',
      theme: ThemeData(fontFamily: 'Pretendard'),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFEFE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 150,
                  width: 500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EmailLoginPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.teal,
                      ),
                      child: Text('로그인', style: TextStyle(fontSize: 16,color:Colors.white)),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.grey.shade400,
                      ),
                      child: Text('회원가입', style: TextStyle(fontSize: 16,color:Colors.white)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class EmailLoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFEFE),
      appBar: AppBar(title: Text('로그인'),backgroundColor: Color(0xFFFDFEFE),),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 회원가입 처리 후 로그인 화면으로
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.teal,
                ),
                child: Text(
                  '로그인',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// 회원가입 화면
class SignUpPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFEFE),
      appBar: AppBar(title: Text('회원가입'),backgroundColor: Color(0xFFFDFEFE),),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '보호자 이메일'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 회원가입 처리 후 로그인 화면으로
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.teal,
                ),
                child: Text(
                  '회원가입',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [MainPage(), CalendarPage(),PillPage(), MyPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFEFE),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '달력'),
          BottomNavigationBarItem(icon: Icon(Icons.add_chart), label: '복약목록'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지')
        ],
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: Column(
        children: [
          Container(
            color: Color(0xFFFDFEFE),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                    'assets/logo.png',
                    height: 50
                ),
                Row(
                  children: [
                    Icon(Icons.emoji_emotions_outlined, color: Colors.black),
                    SizedBox(width: 8),
                    Icon(Icons.notifications_none, color: Colors.black),
                  ],
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 170,
                          decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: Offset(0,3),
                                ),
                              ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 50, color: Colors.white),
                              SizedBox(height: 8),
                              Text('처방전 촬영', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 170,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: Offset(0,3),
                                ),
                              ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, size: 50, color: Colors.teal),
                              SizedBox(height: 8),
                              Text('처방전 업로드', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: days.map((day) {
                    return Column(
                      children: [
                        Text(day, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Icon(Icons.check_circle_outline, color: Colors.grey),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFF8F8F8),
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('오늘의 복약 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ListTile(title: Text('오전: 종합비타민')),
                  ListTile(title: Text('저녁: 위장약')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: Column(
        children: [
          Container(
            color: Color(0xFFFDFEFE),
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('복약 달력', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.emoji_emotions_outlined, color: Colors.black),
                    SizedBox(width: 8),
                    Icon(Icons.notifications_none, color: Colors.black),
                  ],
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFDFEFE),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarFormat: CalendarFormat.month,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Color(0xFFF8F8F8),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('yyyy.MM.dd').format(selectedDay ?? focusedDay)} 복약정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ListTile(title: Text('오전: 종합비타민')),
                  ListTile(title: Text('저녁: 위장약')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PillPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('복약 페이지입니다.'),
    );
  }
}


class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40),

            // 프로필 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 40, color: Colors.lightBlueAccent),
            ),
            SizedBox(height: 20),

            // 이름
            Text(
              '홍길동',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // 이메일
            Text(
              'test@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            SizedBox(height: 30),

            // 구분선
            Divider(thickness: 1, color: Colors.grey[300]),

            // 설정 항목들
            settingTile('환경설정'),
            settingTile('서비스 이용약관'),
            settingTile('회원 탈퇴'),

            Divider(thickness: 1, color: Colors.grey[300]),

            Spacer(),

            // 로그아웃 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    '로그아웃',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 설정 버튼 모양 위젯
  Widget settingTile(String title) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        // 원하는 화면 이동 추가 가능
      },
    );
  }
}