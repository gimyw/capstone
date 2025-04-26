import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // Platform 클래스를 사용하기 위해 필요

Future<void> main() async {
  // async 추가
  // Flutter 바인딩 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit(); // FFI 초기화 호출
    databaseFactory = databaseFactoryFfi; // FFI 데이터베이스 팩토리를 기본으로 설정
    print("Sqflite FFI initialized for Desktop.");
  }

  // 데이터베이스 초기화 (파일 열기 및 테이블 생성 시도)
  // 앱 시작 시 딱 한 번 호출되어 DB 준비
  try {
    await DatabaseHelper().database;
    print("Database initialized successfully.");
  } catch (e) {
    print("Error initializing database: $e");
    // 앱 실행을 계속할지, 아니면 오류 메시지를 보여줄지 결정
  }

  runApp(MyApp());
}

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
                child: Image.asset('assets/logo.png', height: 150, width: 500),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EmailLoginPage()),
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
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.grey.shade400,
                      ),
                      child: Text(
                        '회원가입',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
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

  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFEFE),
      appBar: AppBar(title: Text('로그인'), backgroundColor: Color(0xFFFDFEFE)),
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
                onPressed: () async {
                  String email = emailController.text.trim();
                  String password = passwordController.text; // 비밀번호 가져오기

                  // 이메일, 비밀번호 입력 확인
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')),
                    );
                    return;
                  }

                  try {
                    // DB에서 이메일과 비밀번호 검증
                    Map<String, dynamic>? member = await dbHelper.verifyMember(
                      email,
                      password,
                    );

                    if (member != null) {
                      // 로그인 성공
                      print(
                        '로그인 성공: ${member['email']}, 이름: ${member['member_name']}',
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => HomeScreen(
                            userEmail: member['email'] as String,
                          ),
                        ),
                      );
                    } else {
                      // 로그인 실패 (이메일 없거나 비밀번호 틀림)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('이메일 또는 비밀번호가 잘못되었습니다.'),
                        ), // 구체적인 실패 사유 숨김
                      );
                    }
                  } catch (e) {
                    print('로그인 오류: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
                    );
                  }
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

  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFEFE),
      appBar: AppBar(title: Text('회원가입'), backgroundColor: Color(0xFFFDFEFE)),
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
            //TextField(
            //  controller: passwordController,
            //  decoration: InputDecoration(labelText: '보호자 이메일'),
            //  obscureText: true,
            //),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String name = nameController.text.trim();
                  String email = emailController.text.trim();
                  String password = passwordController.text;
                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('이름, 이메일, 비밀번호를 모두 입력해주세요.')),
                    );
                    return;
                  }
                  if (!email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('유효한 이메일 형식이 아닙니다.')),
                    );
                    return;
                  }
                  Map<String, dynamic> newMember = {
                    'member_name': name,
                    'email': email,
                    'password': password, // 비밀번호 추가
                  };
                  try {
                    // insertMember는 이제 비밀번호를 포함하여 호출됨
                    int id = await dbHelper.insertMember(newMember);
                    if (id != 0) {
                      print('회원가입 성공: $id, $name, $email');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('회원가입 성공! 로그인해주세요.')),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print('회원가입 오류: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('회원가입 중 오류 발생: 이미 사용 중인 이메일일 수 있습니다.'),
                      ),
                    );
                  }
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
  final String userEmail;
  HomeScreen({Key? key, required this.userEmail}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // initState에서 widget.userEmail을 사용하여 페이지 목록 초기화
    _pages = [
      MainPage(userEmail: widget.userEmail),
      CalendarPage(userEmail: widget.userEmail),
      PillPage(userEmail: widget.userEmail), // userEmail 전달
      MyPage(userEmail: widget.userEmail), // userEmail 전달
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFEFE),
      body: IndexedStack(
        // 페이지 상태 유지를 위해 IndexedStack 사용 고려
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // 아이템 4개 이상일 때 라벨 보이게
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '달력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: '복약목록', // 아이콘 변경
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final String userEmail;
  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  MainPage({Key? key, required this.userEmail}) : super(key: key);

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
                Image.asset('assets/logo.png', height: 50),
                Row(
                  children: [
                    Icon(Icons.emoji_emotions_outlined, color: Colors.black),
                    SizedBox(width: 8),
                    Icon(Icons.notifications_none, color: Colors.black),
                  ],
                ),
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
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '처방전 촬영',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: 50,
                                color: Colors.teal,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '처방전 업로드',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
                  children:
                  days.map((day) {
                    return Column(
                      children: [
                        Text(day, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.grey,
                        ),
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
                  Text(
                    '오늘의 복약 정보',
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

class CalendarPage extends StatefulWidget {
  final String userEmail;
  CalendarPage({Key? key, required this.userEmail}) : super(key: key);
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
                Text(
                  '복약 달력',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.emoji_emotions_outlined, color: Colors.black),
                    SizedBox(width: 8),
                    Icon(Icons.notifications_none, color: Colors.black),
                  ],
                ),
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

class PillPage extends StatefulWidget {
  // StatelessWidget -> StatefulWidget 변경
  final String userEmail;
  PillPage({Key? key, required this.userEmail}) : super(key: key);
  @override
  _PillPageState createState() => _PillPageState();
}

class _PillPageState extends State<PillPage> {
  // State 클래스 생성
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _alarmsFuture; // Future 상태 변수

  @override
  void initState() {
    super.initState();
    _loadAlarms(); // 초기 데이터 로드
  }

  // 알람 데이터를 로드하는 함수
  void _loadAlarms() {
    setState(() {
      // FutureBuilder가 re-build 되도록 setState 호출
      _alarmsFuture = dbHelper.getAllAlarmsForUser(widget.userEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFEFE),
      appBar: AppBar(
        // AppBar 추가 (선택적)
        title: Text('복약 목록'),
        backgroundColor: Color(0xFFFDFEFE),
        elevation: 0, // 그림자 제거
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          // FutureBuilder를 사용하여 비동기 데이터 로드 및 UI 구성
          Expanded(
            // 스크롤 가능한 영역을 만들기 위해 Expanded 추가
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _alarmsFuture, // dbHelper 호출 결과를 Future로 사용
              builder: (context, snapshot) {
                // 데이터 로딩 중
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                // 에러 발생 시
                else if (snapshot.hasError) {
                  return Center(child: Text('오류 발생: ${snapshot.error}'));
                }
                // 데이터가 없거나 비어있을 시
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('등록된 복약 알람이 없습니다.'));
                }
                // 데이터 로드 성공 시
                else {
                  final alarms = snapshot.data!; // 로드된 알람 데이터
                  // DataTable을 스크롤 가능하게 SingleChildScrollView 사용
                  return SingleChildScrollView(
                    // 스크롤 방향은 수직이어야 함 (기본값)
                    // scrollDirection: Axis.horizontal, // 가로 스크롤은 필요 없음
                    child: SizedBox(
                      // DataTable 너비 강제 위해 SizedBox 사용
                      width: double.infinity, // 화면 너비만큼
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('약 이름')),
                          DataColumn(label: Text('식사 시간')), // 컬럼 변경
                          DataColumn(label: Text('알람 시간')), // 컬럼 변경
                        ],
                        // alarms 리스트를 DataRow 리스트로 변환
                        rows:
                        alarms
                            .map(
                              (alarm) => DataRow(
                            cells: [
                              DataCell(
                                Text(alarm['MED_NAME'] ?? 'N/A'),
                              ), // null 체크
                              DataCell(
                                Text(alarm['MEAL_TIME'] ?? 'N/A'),
                              ),
                              DataCell(
                                Text(alarm['ALARM_TIME'] ?? 'N/A'),
                              ),
                            ],
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // async 추가
          // TODO: 약/알람 추가 페이지로 이동하는 로직 구현
          // 예시: Navigator.push(context, MaterialPageRoute(builder: (_) => AddAlarmPage(userEmail: widget.userEmail)))
          //      .then((_) => _loadAlarms()); // 추가 후 목록 새로고침
          print('약 추가 버튼 클릭됨');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('약 추가 기능은 아직 구현되지 않았습니다.')));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class MyPage extends StatefulWidget {
  // StatelessWidget -> StatefulWidget 변경
  final String userEmail;

  MyPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // State 클래스 생성
  final dbHelper = DatabaseHelper();
  // 사용자 정보를 담을 Future 또는 직접 변수 선언 (FutureBuilder 사용 권장)
  late Future<Map<String, dynamic>?> _memberFuture;

  @override
  void initState() {
    super.initState();
    _memberFuture = dbHelper.getMemberByEmail(widget.userEmail); // 사용자 정보 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SafeArea(
        // FutureBuilder를 사용하여 사용자 정보 로드
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _memberFuture,
          builder: (context, snapshot) {
            // 로딩 중 또는 에러 시 표시할 위젯 (선택적)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('사용자 정보 로드 오류'));
            }

            // 사용자 정보 (null일 수도 있음)
            final memberData = snapshot.data;
            final memberName =
                memberData?['member_name'] ?? '사용자'; // null 이면 기본값
            final memberEmail = memberData?['email'] ?? '이메일 정보 없음';

            // 기본 Column 구조는 유지
            return Column(
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
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.teal,
                  ), // 색상 변경
                ),
                SizedBox(height: 20),

                // 이름 (DB에서 가져온 값 사용)
                Text(
                  memberName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // 이메일 (DB에서 가져온 값 사용)
                Text(
                  memberEmail,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                SizedBox(height: 30),
                Divider(thickness: 1, color: Colors.grey[300]),
                settingTile('환경설정'),
                settingTile('서비스 이용약관'),
                settingTile('회원 탈퇴'), // TODO: 회원 탈퇴 로직 구현 필요 (DB 삭제 등)
                Divider(thickness: 1, color: Colors.grey[300]),
                Spacer(),

                // 로그아웃 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      // ... 기존 로그아웃 버튼 스타일 및 onPressed 로직 유지 ...
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        // TODO: 실제 로그아웃 처리 (예: 저장된 로그인 정보 삭제)
                        Navigator.pushAndRemoveUntil(
                          // 로그인 화면으로 가고 뒤 스택 모두 제거
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                              (Route<dynamic> route) => false, // 모든 이전 라우트 제거
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
            );
          },
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
