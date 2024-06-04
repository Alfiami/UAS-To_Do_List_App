import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/beranda_screen.dart';
import 'screens/kelender_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/reminder_screen.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart'; // Import the splash screen

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Text(
          'Terjadi kesalahan! Silakan coba lagi.',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  };

  runApp(TodoListApp());
}

class TodoListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'To Do List App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.pink, // Mengubah warna ikon yang dipilih
            selectedLabelStyle: TextStyle(color: Colors.pink), // Mengubah warna teks yang dipilih
          ),
        ),
        initialRoute: '/', // Set initial route to splash screen
        routes: {
          '/': (context) => SplashScreen(), // Add the splash screen route
          '/main': (context) => MainScreen(), // Add the main screen route
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    BerandaScreen(),
    KalenderScreen(),
    TimerScreen(),
    ReminderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminder',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed, // Agar ikon tidak bergeser
        selectedItemColor: Colors.pink, // Mengubah warna ikon yang dipilih
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}