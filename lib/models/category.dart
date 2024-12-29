import 'alarm_sound.dart';

class TodoCategory {
  String name;
  List<Todo> todos;
  
  TodoCategory({required this.name, List<Todo>? todos}) 
    : todos = todos ?? [];

  int get totalTodos => todos.length;
  int get completedTodos => todos.where((todo) => todo.isCompleted).length;
}

class Todo {
  String title;
  bool isCompleted;
  DateTime? reminderDateTime;
  AlarmSound? alarmSound;

  Todo({
    required this.title, 
    this.isCompleted = false,
    this.reminderDateTime,
    this.alarmSound,
  });
} 