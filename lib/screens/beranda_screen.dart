
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class BerandaScreen extends StatefulWidget {
  @override
  _BerandaScreenState createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final selectedDate = taskProvider.selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: selectedDate != null
            ? Text(
                'Catatan untuk tanggal: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              )
            : Text(
                'To Do List App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35.0,
                  fontFamily: 'Crafts', // Use the new font
                ),
              ),
        backgroundColor: Colors.pink,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Adjust vertical padding here
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 40.0, // Adjust the height as needed
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // Aksi pencarian tugas
                    taskProvider.filterTasks(searchController.text);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: taskProvider.tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/beranda.png', height: 200, width: 200),
                  SizedBox(height: 20),
                  Text(
                    'Add your first task!',
                    style: TextStyle(
                      fontSize: 24.0, 
                      fontWeight: FontWeight.bold, 
                      color: Color.fromARGB(255, 238, 92, 140)
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                final title = task.title;
                final note = task.note ?? '';
                final searchValue = searchController.text.toLowerCase();
                final titleMatches = title.toLowerCase().contains(searchValue);
                final noteMatches = note.toLowerCase().contains(searchValue);
                return titleMatches || noteMatches
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Dismissible(
                          key: Key(task.id),
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              taskProvider.toggleTaskCompletion(task);
                            }
                          },
                          child: Card(
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: ListTile(
                              leading: IconButton(
                                icon: Icon(
                                  task.isFavorite ? Icons.star : Icons.star_border,
                                  color: task.isFavorite ? Colors.pink : null,
                                ),
                                onPressed: () {
                                  taskProvider.toggleFavorite(task);
                                },
                              ),
                              title: RichText(
                                text: TextSpan(
                                  text: titleMatches ? '' : title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                    color: titleMatches ? Colors.black : Colors.black.withOpacity(0.5),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: titleMatches ? title.substring(0, searchValue.length) : '',
                                      style: TextStyle(color: Colors.pink),
                                    ),
                                    TextSpan(
                                      text: titleMatches ? title.substring(searchValue.length) : '',
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: note.isNotEmpty
                                  ? RichText(
                                      text: TextSpan(
                                        text: noteMatches ? '' : note,
                                        style: TextStyle(
                                          color: noteMatches ? Colors.pink : Colors.black.withOpacity(0.5),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: noteMatches ? note.substring(0, searchValue.length) : '',
                                            style: TextStyle(color: Colors.pink),
                                          ),
                                          TextSpan(
                                            text: noteMatches ? note.substring(searchValue.length) : '',
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                              trailing: Wrap(
                                spacing: 8.0,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.edit_note),
                                    onPressed: () {
                                      _showEditDialog(context, task, taskProvider);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline),
                                    onPressed: () => taskProvider.deleteTask(index),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox();
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context, taskProvider);
        },
        child: Icon(Icons.add, color: Colors.white), // Ubah warna ikon menjadi putih
        backgroundColor: Colors.pink,
      ),
    );
  }

  void _showAddDialog(BuildContext context, TaskProvider taskProvider) {
    TextEditingController titleController = TextEditingController();
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  taskProvider.addTask(
                    Task(
                      id: DateTime.now().toString(),
                      title: titleController.text,
                      note: noteController.text.isNotEmpty ? noteController.text : null,
                      date: DateTime.now(),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child:Text('Add', style: TextStyle(color: Colors.pink),
            ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Task task, TaskProvider taskProvider) {
    TextEditingController titleController = TextEditingController(text: task.title);
    TextEditingController noteController = TextEditingController(text: task.note ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Tittle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  taskProvider.updateTask(
                    task,
                    titleController.text,
                    noteController.text.isNotEmpty ? noteController.text : null,
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}