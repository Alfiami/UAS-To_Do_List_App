import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class ReminderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final List<Task> tasksWithDate = taskProvider.tasks.where((task) => task.date != null).toList();

    // Mengelompokkan catatan berdasarkan tanggal
    final Map<DateTime, List<Task>> groupedTasks = {};
    tasksWithDate.forEach((task) {
      groupedTasks.putIfAbsent(_removeTime(task.date!), () => []);
      groupedTasks[_removeTime(task.date!)]!.add(task);
    });

    // Mengurutkan tanggal secara ascending
    final sortedDates = groupedTasks.keys.toList()..sort((a, b) => a.compareTo(b));

    // Menghitung jumlah tugas yang sudah selesai dan yang belum selesai
    int completedTasksCount = tasksWithDate.where((task) => task.isCompleted).length;
    int pendingTasksCount = tasksWithDate.length - completedTasksCount;

    // Menghitung persentase tugas yang sudah selesai dan yang belum selesai
    double completedPercentage = tasksWithDate.isEmpty ? 0 : completedTasksCount / tasksWithDate.length;
    double pendingPercentage = tasksWithDate.isEmpty ? 0 : pendingTasksCount / tasksWithDate.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Summary',
          style: TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
        ),
        backgroundColor: Colors.pink, // Ubah warna latar belakang menjadi pink
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          _buildProgressBar('Completed', completedPercentage, '$completedTasksCount/${tasksWithDate.length}'),
          SizedBox(height: 16.0),
          _buildProgressBar('Pending', pendingPercentage, '$pendingTasksCount/${tasksWithDate.length}'),
          SizedBox(height: 16.0),
          Expanded(
            child: tasksWithDate.isEmpty
                ? Center(
              child: Text(
                'There are no tasks to be done today 😴',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            )
                : ListView.builder(
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final tasksOnDate = groupedTasks[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Column(
                      children: tasksOnDate
                          .map((task) => _buildTaskItem(context, task, taskProvider))
                          .toList(),
                    ),
                    SizedBox(height: 16.0),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk memformat tanggal
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.add(Duration(days: 1)))) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Fungsi untuk memeriksa apakah dua tanggal sama
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  // Fungsi untuk menghapus informasi waktu dari tanggal
  DateTime _removeTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // Fungsi untuk membangun item catatan
  Widget _buildTaskItem(BuildContext context, Task task, TaskProvider taskProvider) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (bool? value) {
          taskProvider.toggleTaskCompletion(task);
        },
        checkColor: Colors.white, // Set warna ceklis menjadi putih
        activeColor: Colors.pink, // Set warna latar belakang ceklis menjadi pink
      ),
      title: Text(
        task.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      subtitle: task.isCompleted ? null : Text(
        task.note ?? '',
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      trailing: Text(
        'At ${task.date!.hour}:${task.date!.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // Fungsi untuk membangun progres bar untuk tugas selesai atau belum selesai
  Widget _buildProgressBar(String label, double percentage, String progressText) {
    Color progressBarColor;
    if (percentage <= 0.33) {
      progressBarColor = Colors.pink[100]!;
    } else if (percentage <= 0.66) {
      progressBarColor = Colors.pink[300]!;
    } else {
      progressBarColor = Colors.pink[600]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            height: 12.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6.0),
            ),
            child : FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: progressBarColor,
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
