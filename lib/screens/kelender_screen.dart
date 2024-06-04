import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Import package intl
import '../providers/task_provider.dart';
import '../models/task.dart';

class KalenderScreen extends StatefulWidget {
  @override
  _KalenderScreenState createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  DateTime _selectedDay = DateTime.now();

  // Daftar warna catatan
  final List<Color> _noteColors = [
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.pink,
    const Color.fromARGB(255, 156, 243, 33),
    Color.fromARGB(255, 33, 236, 243),
    // Anda bisa menambahkan warna lain di sini sesuai kebutuhan
  ];

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kalender',
          style: TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
        ),
        backgroundColor: Colors.pink, // Ubah warna latar belakang menjadi pink
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.pink, // Warna latar belakang sel yang dipilih menjadi pink
                shape: BoxShape.circle, // Mengubah bentuk menjadi lingkaran
              ),
              markerDecoration: BoxDecoration(
                color: Colors.pink, // Warna strip di bawah tanggal
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.0),
                  bottomRight: Radius.circular(4.0),
                ),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final tasksForDate = taskProvider.tasks.where((task) {
                  return isSameDay(task.date, date);
                }).toList();
                if (tasksForDate.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      color: Colors.pink, // Warna strip di bawah tanggal
                      width: 16,
                      height: 4,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                if (isSameDay(task.date, _selectedDay)) {
                  final colorIndex = index % _noteColors.length;
                  final noteColor = _noteColors[colorIndex];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: noteColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.note ?? ''),
                        onTap: () {
                          _showTaskDetailsDialog(context, task);
                        },
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, Task task) {
    TextEditingController titleController = TextEditingController(text: task.title);
    TextEditingController noteController = TextEditingController(text: task.note ?? '');
    TextEditingController dateController = TextEditingController(
      text: task.date != null ? DateFormat('yyyy-MM-dd').format(task.date!) : '', // Format tanggal
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Task Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Title:'),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter task title',
                  ),
                ),
                SizedBox(height: 16),
                Text('Note:'),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Enter additional notes (optional)',
                  ),
                ),
                SizedBox(height: 16),
                Text('Date:'),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: task.date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        task.date = selectedDate;
                        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate); // Format tanggal
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Select date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  task.title = titleController.text;
                  task.note = noteController.text.isNotEmpty ? noteController.text : null;

                  Provider.of<TaskProvider>(context, listen: false).updateTask(task, task.title, task.note);

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter a title for the task.'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
