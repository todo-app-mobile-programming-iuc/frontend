import 'package:flutter/material.dart';
import '../models/category.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/sound_selection_dialog.dart';
import '../models/alarm_sound.dart';

class TodoListPage extends StatefulWidget {
  final TodoCategory category;
  final VoidCallback onTodoListChanged;

  static List<Todo> todos = [];

  TodoListPage({
    required this.category,
    required this.onTodoListChanged,
  });

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _textController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _scheduleNotification(Todo todo) async {
    if (todo.reminderDateTime == null) return;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'todo_reminders',
      'Todo Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
      todo.hashCode,
      'Todo Reminder',
      todo.title,
      todo.reminderDateTime!,
      platformChannelSpecifics,
    );
  }

  Future<void> _addTodoWithReminder(String title) async {
    // Show date picker
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate == null) return;

    // Show time picker
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    // Combine date and time
    final DateTime reminderDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Show sound selection dialog
    final AlarmSound? selectedSound = await showDialog<AlarmSound>(
      context: context,
      builder: (context) => SoundSelectionDialog(),
    );

    // Create new todo with reminder and sound
    final todo = Todo(
      title: title,
      reminderDateTime: reminderDateTime,
      alarmSound: selectedSound ?? AlarmSound.defaultSounds[0],
    );

    setState(() {
      widget.category.todos.add(todo);
      TodoListPage.todos.add(todo);
    });

    // Schedule notification
    await _scheduleNotification(todo);

    widget.onTodoListChanged();
    _textController.clear();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder set for ${todo.reminderDateTime!.toString().substring(0, 16)}',
        ),
        backgroundColor: Color(0xFFCDC1FF),
      ),
    );
  }

  void _toggleTodo(int index) {
    setState(() {
      widget.category.todos[index].isCompleted = 
          !widget.category.todos[index].isCompleted;
    });
    widget.onTodoListChanged();
  }

  void _removeTodo(int index) {
    setState(() {
      widget.category.todos.removeAt(index);
      TodoListPage.todos.removeAt(index);
    });
    widget.onTodoListChanged();
  }

  Future<void> _editTodo(Todo todo, int index) async {
    TextEditingController editController = TextEditingController(text: todo.title);
    DateTime? newDate = todo.reminderDateTime;
    TimeOfDay? newTime = todo.reminderDateTime != null 
        ? TimeOfDay.fromDateTime(todo.reminderDateTime!)
        : null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editController,
              decoration: InputDecoration(
                hintText: 'Edit todo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: newDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        newDate = selectedDate;
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text('Set Date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCDC1FF),
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: newTime ?? TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        newTime = selectedTime;
                      }
                    },
                    icon: Icon(Icons.access_time),
                    label: Text('Set Time'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCDC1FF),
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.isNotEmpty) {
                setState(() {
                  todo.title = editController.text;
                  if (newDate != null && newTime != null) {
                    todo.reminderDateTime = DateTime(
                      newDate!.year,
                      newDate!.month,
                      newDate!.day,
                      newTime!.hour,
                      newTime!.minute,
                    );
                    _scheduleNotification(todo);
                  }
                });
                widget.onTodoListChanged();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFCCEA),
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFBFECFF),
        title: Text(
          widget.category.name,
          style: TextStyle(color: Colors.black87),
        ),
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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.category.todos.length,
                itemBuilder: (context, index) {
                  final todo = widget.category.todos[index];
                  return _buildTodoItem(todo, index);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFFBFECFF).withOpacity(0.9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Add a new todo',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF6E3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          _addTodoWithReminder(_textController.text);
                        }
                      },
                      icon: Icon(Icons.add),
                      color: Colors.black87,
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

  Widget _buildTodoItem(Todo todo, int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Color(0xFFFFCCEA).withOpacity(0.9),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => _toggleTodo(index),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted 
                ? TextDecoration.lineThrough 
                : null,
          ),
        ),
        subtitle: todo.reminderDateTime != null
            ? Text(
                'Reminder: ${todo.reminderDateTime!.toString().substring(0, 16)}',
                style: TextStyle(fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _editTodo(todo, index),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeTodo(index),
            ),
          ],
        ),
      ),
    );
  }
}