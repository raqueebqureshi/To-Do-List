import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';

class TodoHome extends StatefulWidget {
  @override
  _TodoHomeState createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? tasksJson = prefs.getString('tasks');
      print("Loaded tasks from storage: $tasksJson");
      if (tasksJson != null) {
        List<dynamic> tasks = jsonDecode(tasksJson);
        setState(() {
          _tasks.addAll(tasks.map((task) => task as Map<String, dynamic>));
        });
      }
    } catch (e) {
      print("Error loading tasks: $e");
    }
  }

  Future<void> _saveTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String tasksJson = jsonEncode(_tasks);
      print("Saving tasks to storage: $tasksJson");
      await prefs.setString('tasks', tasksJson);
    } catch (e) {
      print("Error saving tasks: $e");
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.insert(0, {"title": _taskController.text, "isDone": false});
        _taskController.clear();
        _listKey.currentState?.insertItem(0);
      });

      _saveTasks();

      Fluttertoast.showToast(
        msg: "Task added successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Please enter a task!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]["isDone"] = !_tasks[index]["isDone"];
    });
    _saveTasks();

    if (_tasks.every((task) => task["isDone"])) {
      setState(() {
        _showCelebration = true;
      });

      Future.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          _showCelebration = false;
        });
      });
    }
  }

  void _deleteTask(int index) {
    // Store the task data before removing it
    final removedTask = _tasks[index];

    // Remove the task from the list
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedTask, animation),
      duration: const Duration(milliseconds: 300),
    );

    setState(() {
      _tasks.removeAt(index);
    });

    _saveTasks();

    Fluttertoast.showToast(
      msg: "Task deleted!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

// Update _buildRemovedItem to accept the task data directly
  Widget _buildRemovedItem(
      Map<String, dynamic> task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: ListTile(
          leading: Checkbox(
            value: task["isDone"],
            onChanged: null, // Disable the checkbox during removal
          ),
          title: Text(
            task["title"],
            style: GoogleFonts.poppins(
              fontSize: 16,
              decoration: task["isDone"] ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: null, // Disable the delete button during removal
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("To-Do List",
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                textStyle: const TextStyle(color: Colors.white))),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade200,
                          spreadRadius: 2,
                          blurRadius: 8),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            onSubmitted: (e) => _addTask(),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter a new task...",
                              hintStyle:
                                  GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Colors.blueAccent, size: 32),
                          onPressed: _addTask,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _tasks.isEmpty
                    ? Center(
                        child: Text(
                          "No tasks added yet!",
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : AnimatedList(
                        key: _listKey,
                        initialItemCount: _tasks.length,
                        itemBuilder: (context, index, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            )),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              color: Colors.white,
                              child: ListTile(
                                leading: Checkbox(
                                  value: _tasks[index]["isDone"],
                                  activeColor: Colors.black,
                                  onChanged: (value) => _toggleTask(index),
                                ),
                                title: Text(
                                  _tasks[index]["title"],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    decoration: _tasks[index]["isDone"]
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_forever,
                                      color: Colors.redAccent),
                                  onPressed: () => _deleteTask(index),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (_showCelebration)
            Positioned.fill(
              child: Container(
                color: Colors.white54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/celebration.json',
                        width: 200,
                        height: 200,
                        repeat: false,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "All tasks completed!",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
