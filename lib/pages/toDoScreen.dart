import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:lottie/lottie.dart'; // Import Lottie package

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _showCelebration = false; // State to control celebration animation

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the screen initializes
  }

  // Load tasks from local storage
  Future<void> _loadTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? tasksJson = prefs.getString('tasks');
      print("Loaded tasks from storage: $tasksJson"); // Debugging
      if (tasksJson != null) {
        List<dynamic> tasks = jsonDecode(tasksJson);
        setState(() {
          _tasks.addAll(tasks.map((task) => task as Map<String, dynamic>));
        });
      }
    } catch (e) {
      print("Error loading tasks: $e"); // Debugging
    }
  }

  // Save tasks to local storage
  Future<void> _saveTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String tasksJson = jsonEncode(_tasks);
      print("Saving tasks to storage: $tasksJson"); // Debugging
      await prefs.setString('tasks', tasksJson);
    } catch (e) {
      print("Error saving tasks: $e"); // Debugging
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.insert(0, {"title": _taskController.text, "isDone": false});
        _taskController.clear();
        _listKey.currentState?.insertItem(0); // Animate the insertion
      });

      _saveTasks(); // Save tasks to local storage

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
    _saveTasks(); // Save tasks to local storage

    // Check if all tasks are done
    if (_tasks.every((task) => task["isDone"])) {
      setState(() {
        _showCelebration = true; // Show celebration animation
      });

      // Hide the celebration animation after 3 seconds
      Future.delayed(Duration(milliseconds: 2000), () {
        setState(() {
          _showCelebration = false; // Hide celebration animation
        });
      });
    }
  }

  void _deleteTask(int index) {
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(index, animation),
      duration: Duration(milliseconds: 300),
    );

    setState(() {
      _tasks.removeAt(index);
    });

    _saveTasks(); // Save tasks to local storage

    Fluttertoast.showToast(
      msg: "Task deleted!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Build a removed item for animation
  Widget _buildRemovedItem(int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: ListTile(
          leading: Checkbox(
            value: _tasks[index]["isDone"],
            onChanged: (value) => _toggleTask(index),
          ),
          title: Text(
            _tasks[index]["title"],
            style: GoogleFonts.poppins(
              fontSize: 16,
              decoration:
                  _tasks[index]["isDone"] ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteTask(index),
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
                textStyle: TextStyle(color: Colors.white))),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Stack(
        // Use Stack to overlay the animation
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12),
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
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                          icon: Icon(Icons.add_circle,
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
                              begin: Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            )),
                            child: Card(
                              margin: EdgeInsets.symmetric(
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
                                  icon: Icon(Icons.delete_forever,
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
          // Celebration Animation
          if (_showCelebration)
            Positioned.fill(
              // Fill the entire screen
              child: Container(
                color: Colors.white54, // Optional: semi-transparent background
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/celebration.json', // Add your Lottie file here
                        width: 200,
                        height: 200,
                        repeat: false,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20),
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
