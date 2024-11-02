class TaskList {
  final String name;
  List<Task> tasks;

  TaskList({
    required this.name,
    List<Task>? tasks,
  }) : tasks = tasks ?? [];

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((task) => task.isCompleted).length;
  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;
}

class Task {
  String title;
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  });
} 