

import 'package:calendar_timeline_sbk/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:todotodo/database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late String _eventName = '';
  late TextEditingController _eventNameController;
  late TextEditingController _selectedStartTimeController;
  late TextEditingController _selectedEndTimeController;

  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
    _resetSelectedTime();
    _eventNameController = TextEditingController();
    _selectedStartTimeController = TextEditingController();
    _selectedEndTimeController = TextEditingController();
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now().add(const Duration(days: 2));
  }

  void _resetSelectedTime() {
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = TimeOfDay.now();
  }

  void _showEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 40),
              TextField(
                onChanged: (value) => _eventName = value,
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(200),
                    borderSide: BorderSide(color: Color.fromARGB(255, 186, 246, 231)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 3.0),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                onTap: () => _selectDate(context),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(200)),
                ),
                controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      onTap: () => _selectStartTime(context),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        labelStyle: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(200)),
                      ),
                      controller: _selectedStartTimeController,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      onTap: () => _selectEndTime(context),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        labelStyle: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(200)),
                      ),
                      controller: _selectedEndTimeController,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
  onPressed: () {
    Navigator.of(context).pop(); // إغلاق الحوار بدون حفظ
  },
  child: Text('Cancel'), // إضافة معلمة الطفرة هنا
),
            ElevatedButton(
              onPressed: () async {
                // إنشاء كائن Event وملء البيانات من الحقول المدخلة
                Event event = Event(
                  eventName: _eventName,
                  startTime: _selectedStartTime,
                  endTime: _selectedEndTime,
                  date: _selectedDate,
                );

                // قم بإضافة الحدث إلى قاعدة البيانات
                await DatabaseHelper.instance.insert(event.toMap());

                // عرض تفاصيل الحدث
                _showEventDetails();

                // إغلاق الحوار بعد الحفظ
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEventDetails() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Event Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 10),
              Text('Event Name: $_eventName', style: TextStyle(fontSize: 16)),
              Text('Start Time: ${_selectedStartTime.format(context)}', style: TextStyle(fontSize: 16)),
              Text('End Time: ${_selectedEndTime.format(context)}', style: TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 4)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _eventNameController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );

    if (pickedStartTime != null && pickedStartTime != _selectedStartTime) {
      setState(() {
        _selectedStartTime = pickedStartTime;
        _selectedStartTimeController.text = pickedStartTime.format(context);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedEndTime = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );

    if (pickedEndTime != null && pickedEndTime != _selectedEndTime) {
      setState(() {
        _selectedEndTime = pickedEndTime;
        _selectedEndTimeController.text = pickedEndTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.tealAccent[100]),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 450,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: CalendarTimeline(
                    showYears: false,
                    initialDate: _selectedDate,firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 4)),
                    onDateSelected: (date) => setState(() => _selectedDate = date),
                    dotsColor: Color(0xFF61A0A6),
                    dayColor: Color(0xFF555B5C),
                    dayNameColor: Colors.white,
                    activeDayColor: Colors.white,
                    inactiveDayNameColor: Colors.black,
                    activeBackgroundDayColor: Color(0xFF61A0A6),
                    selectableDayPredicate: (date) => true,
                    locale: 'en',
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper.instance.queryAllRows(),
                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        var event = Event.fromMap(snapshot.data![index]);
                        if (event.date == _selectedDate) {
                          return ListTile(
                            title: Text(event.eventName),
                            subtitle: Text('${event.startTime} - ${event.endTime}'),
                            // يمكنك إضافة المزيد من التفاصيل أو الإجراءات هنا
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: FloatingActionButton(
                onPressed: _showEventDialog, // عرض الحوار عند الضغط
                child: Icon(Icons.add, color: Colors.white),
                backgroundColor: Color(0xFF61A0A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class Event {
  final String eventName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final DateTime date;

  Event({
    required this.eventName,
    required this.startTime,
    required this.endTime,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'date': date.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventName: map['eventName'],
      startTime: TimeOfDay(
        hour: int.parse(map['startTime'].split(':')[0]),
        minute: int.parse(map['startTime'].split(':')[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(map['endTime'].split(':')[0]),
        minute: int.parse(map['endTime'].split(':')[1]),
      ),
      date: DateTime.parse(map['date']),
    );
  }
}