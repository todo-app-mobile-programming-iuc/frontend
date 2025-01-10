import 'package:flutter/material.dart';
import '../models/category.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/sound_selection_dialog.dart';
import '../models/alarm_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

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

class _TodoListPageState extends State<TodoListPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  late AnimationController _addTodoController;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _addTodoController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _addTodoController.dispose();
    super.dispose();
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
      backgroundColor: Color(0xFFF8F9FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.category.name,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.category.todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Color(0xFFCDC1FF).withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: widget.category.todos.length,
                    itemBuilder: (context, index) {
                      final todo = widget.category.todos[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) => _removeTodo(index),
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _editTodo(todo, index),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Transform.scale(
                                          scale: 1.2,
                                          child: Checkbox(
                                            value: todo.isCompleted,
                                            onChanged: (bool? value) => _toggleTodo(index),
                                            shape: CircleBorder(),
                                            activeColor: Color(0xFFCDC1FF),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              todo.title,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                decoration: todo.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: todo.isCompleted
                                                    ? Colors.black38
                                                    : Colors.black87,
                                              ),
                                            ),
                                            if (todo.reminderDateTime != null)
                                              Padding(
                                                padding: EdgeInsets.only(top: 4),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 14,
                                                      color: Color(0xFFCDC1FF),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      DateFormat('MMM d, h:mm a')
                                                          .format(todo.reminderDateTime!),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Add a new task...',
                        hintStyle: GoogleFonts.poppins(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFCDC1FF), Color(0xFFFFCCEA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (_textController.text.isNotEmpty) {
                          _addTodoWithReminder(_textController.text);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}