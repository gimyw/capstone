import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('알람 추가')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _medNameController,
                decoration: InputDecoration(labelText: '약 이름'),
                validator: (value) => value!.isEmpty ? '약 이름을 입력하세요' : null,
              ),
              DropdownButtonFormField<String>(
                value: _mealTime,
                decoration: InputDecoration(labelText: '복용 시간대'),
                items: ['MORNING', 'LUNCH', 'DINNER']
                    .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                    .toList(),
                onChanged: (value) => setState(() => _mealTime = value!),
              ),
              TextFormField(
                controller: _alarmTimeController,
                decoration: InputDecoration(labelText: '알람 시간 (예: 08:00)'),
                validator: (value) => value!.isEmpty ? '시간을 입력하세요' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
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
                        'START_DATE': DateTime.now().toIso8601String().split('T')[0],
                        'END_DATE': null,
                      });
                    });

                    Navigator.pop(context, true);
                  }
                },
                child: Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _insertMedicationIfNeeded(DatabaseHelper dbHelper, String medName) async {
    final db = await dbHelper.database;
    final existing = await db.query('medications', where: 'med_name = ?', whereArgs: [medName]);

