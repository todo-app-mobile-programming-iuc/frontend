import 'package:flutter/material.dart';
import '../models/task_list.dart';
import '../models/category.dart';
import 'todo_list_page.dart';
import '../services/storage_service.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskList> taskLists = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTodoLists();  // Load data when screen initializes
  }

  void _addNewCategory() {
    TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Category'),
        content: TextField(
          controller: categoryController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  taskLists.add(TaskList(
                    name: categoryController.text,
                    tasks: [],
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void loadTodoLists() async {
    // Assuming you're using some storage service
    final lists = await StorageService.getTaskLists();  // Implement this based on your storage method
    setState(() {
      taskLists = lists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            Expanded(
              child: taskLists.isEmpty 
                  ? _buildEmptyState()
                  : _buildGridView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCategory,
        backgroundColor: Color(0xFFFFCCEA),
        child: Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Hamburger menu functionality
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                'Yetiştir',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to profile page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFCDC1FF),
              child: Icon(Icons.person, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search lists...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No categories yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add a new category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5, // Changed to make cards more rectangular
        ),
        itemCount: taskLists.length,
        itemBuilder: (context, index) {
          return _buildListCard(taskLists[index]);
        },
      ),
    );
  }

  Widget _buildListCard(TaskList list) {
    return GestureDetector(
      onTap: () async {
        final TodoCategory category = TodoCategory(
          name: list.name,
          todos: list.tasks.map((task) => 
            Todo(
              title: task.title,
              isCompleted: task.isCompleted,
            )
          ).toList(),
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoListPage(
              category: category,
              onTodoListChanged: () {
                setState(() {
                  var index = taskLists.indexWhere((tl) => tl.name == list.name);
                  if (index != -1) {
                    taskLists[index] = TaskList(
                      name: list.name,
                      tasks: category.todos.map((todo) =>
                        Task(
                          title: todo.title,
                          isCompleted: todo.isCompleted,
                        )
                      ).toList(),
                    );
                  }
                });
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Color(0xFFCDC1FF),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                list.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${list.completedTasks}/${list.totalTasks} Tasks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: list.progress, // `progress` here reflects task completion percentage
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFBFECFF),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 