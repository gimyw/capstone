import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class AddAlarmPage extends StatefulWidget {
  final String userEmail;
  AddAlarmPage({required this.userEmail});

  @override
  _AddAlarmPageState createState() => _AddAlarmPageState();
}

class _AddAlarmPageState extends State<AddAlarmPage> {
  final _formKey = GlobalKey<FormState>();
  final _medNameController = TextEditingController();
  final _alarmTimeController = TextEditingController();
  String _mealTime = 'MORNING';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('알람 추가'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _medNameController,
                    decoration: InputDecoration(labelText: '약 이름'),
                    validator: (value) => value!.isEmpty ? '약 이름을 입력하세요' : null,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _mealTime,
                    decoration: InputDecoration(labelText: '복용 시간대'),
                    items: ['MORNING', 'LUNCH', 'DINNER']
                        .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                        .toList(),
                    onChanged: (value) => setState(() => _mealTime = value!),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _alarmTimeController,
                    decoration: InputDecoration(labelText: '알람 시간 (예: 08:00)'),
                    validator: (value) => value!.isEmpty ? '시간을 입력하세요' : null,
                  ),
                  SizedBox(height: 16),
                  // 복용 시작일 선택
                  Text('복용 시작일', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  OutlinedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: Text(
                      _startDate == null
                          ? '날짜 선택'
                          : DateFormat('yyyy-MM-dd').format(_startDate!),
                    ),
                  ),
                  SizedBox(height: 16),
                  // 복용 종료일 선택
                  Text('복용 종료일', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  OutlinedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                    child: Text(
                      _endDate == null
                          ? '날짜 선택 (선택사항)'
                          : DateFormat('yyyy-MM-dd').format(_endDate!),
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final dbHelper = DatabaseHelper();
                          final medName = _medNameController.text.trim();

                          await _insertMedicationIfNeeded(dbHelper, medName);

                          await dbHelper.database.then((db) {
                            db.insert('MEDICATION_ALARMS', {
                              'EMAIL': widget.userEmail,
                              'MED_NAME': medName,
                              'MEAL_TIME': _mealTime,
                              'ALARM_TIME': _alarmTimeController.text.trim(),
                              'START_DATE': _startDate != null
                                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                  : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                              'END_DATE': _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
                            });
                          });

                          Navigator.pop(context, true);
                        }
                      },
                      child: Text('저장'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _insertMedicationIfNeeded(DatabaseHelper dbHelper, String medName) async {
    final db = await dbHelper.database;
    final existing = await db.query('medications', where: 'med_name = ?', whereArgs: [medName]);
    if (existing.isEmpty) {
      await db.insert('medications', {'med_name': medName, 'description': ''});
    }
  }
}