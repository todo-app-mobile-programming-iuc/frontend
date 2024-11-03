import 'package:flutter/material.dart';

class AlarmPage extends StatefulWidget {
  static List<TimeOfDay> alarms = [];

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  void _addAlarm() async {
    final TimeOfDay? selectedTime = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set Alarm Time',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TimePickerDialog(
                  initialTime: TimeOfDay.now(),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          TimeOfDay.now(), // Replace with selected time
                        );
                      },
                      child: Text('Set'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFCCEA),
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        AlarmPage.alarms.add(selectedTime);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm set for ${selectedTime.format(context)}'),
          backgroundColor: Color(0xFFCDC1FF),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Color(0xFFBFECFF),
        title: Text('Alarms', style: TextStyle(color: Colors.black87)),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCDC1FF),
              Color(0xFFF6E3FF),
            ],
          ),
        ),
        child: AlarmPage.alarms.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 64,
                      color: Colors.black54,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No alarms set',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _addAlarm,
                      icon: Icon(Icons.add_alarm),
                      label: Text('Add Alarm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFCCEA),
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: AlarmPage.alarms.length + 1,
                itemBuilder: (context, index) {
                  if (index == AlarmPage.alarms.length) {
                    return Center(
                      child: ElevatedButton.icon(
                        onPressed: _addAlarm,
                        icon: Icon(Icons.add_alarm),
                        label: Text('Add Alarm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFCCEA),
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  }
                  
                  final alarm = AlarmPage.alarms[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    color: Color(0xFFFFCCEA).withOpacity(0.9),
                    child: ListTile(
                      leading: Icon(Icons.alarm, color: Colors.black87),
                      title: Text(
                        alarm.format(context),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            AlarmPage.alarms.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
} 