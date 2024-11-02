import 'package:flutter/material.dart';
import '../models/category.dart';

class TodoListPage extends StatefulWidget {
  final TodoCategory category;
  final VoidCallback onTodoListChanged;

  TodoListPage({
    required this.category,
    required this.onTodoListChanged,
  });

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _textController = TextEditingController();

  void _addTodo(String title) {
    setState(() {
      widget.category.todos.add(Todo(title: title));
    });
    widget.onTodoListChanged();
    _textController.clear();
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
    });
    widget.onTodoListChanged();
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
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeTodo(index),
                      ),
                    ),
                  );
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
                          _addTodo(_textController.text);
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
} 