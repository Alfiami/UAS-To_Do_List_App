import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:async';
import 'my_player.dart';
import 'package:numberpicker/numberpicker.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  late Timer _notificationTimer;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  bool _isTimerRunning = false;

  TextEditingController _noteController = TextEditingController();

  void startTimer() {
    if (_hours == 0 && _minutes == 0 && _seconds == 0) {
      return;
    }
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_hours == 0 && _minutes == 0 && _seconds == 0) {
          timer.cancel();
          FlutterRingtonePlayer.playAlarm();
          _showNotification();
          _startNotificationSound();
        } else {
          setState(() {
            if (_seconds == 0) {
              if (_minutes == 0) {
                if (_hours > 0) {
                  _hours--;
                  _minutes = 59;
                  _seconds = 59;
                }
              } else {
                _minutes--;
                _seconds = 59;
              }
            } else {
              _seconds--;
            }
          });
        }
      },
    );
    setState(() {
      _isTimerRunning = true;
    });
  }

  void _startNotificationSound() {
    _notificationTimer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        FlutterRingtonePlayer.playAlarm();
        MyPlayer().playLocal();
      },
    );
  }

  void _stopNotificationSound() {
    if (_notificationTimer.isActive) {
      _notificationTimer.cancel();
    }
  }

  void _showNotification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Timer Finished'),
          content: Text('Your timer has finished!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _stopNotificationSound();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Timer',
          style: TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
        ),
        backgroundColor: Colors.pink, // Ubah warna latar belakang menjadi pink
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          NumberPicker(
                            minValue: 0,
                            maxValue: 23,
                            value: _hours,
                            onChanged: (value) => setState(() => _hours = value),
                          ),
                          NumberPicker(
                            minValue: 0,
                            maxValue: 59,
                            value: _minutes,
                            onChanged: (value) => setState(() => _minutes = value),
                          ),
                          NumberPicker(
                            minValue: 0,
                            maxValue: 59,
                            value: _seconds,
                            onChanged: (value) => setState(() => _seconds = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  border: OutlineInputBorder(),
                  fillColor: Colors.pink[100], // Warna latar belakang soft pink
                  filled: true,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _isTimerRunning ? null : startTimer,
                    child: Text(
                      'Start',
                      style: TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Warna latar belakang aksen pink
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _timer.cancel();
                      setState(() {
                        _isTimerRunning = false;
                      });
                    },
                    child: Text(
                      'Pause',
                      style: TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Warna latar belakang aksen pink
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hours = 0;
                        _minutes = 0;
                        _seconds = 0;
                        _timer.cancel();
                        _stopNotificationSound();
                        _isTimerRunning = false;
                        _noteController.clear();
                      });
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(color: Colors.white), // Ubah warna teks menjadi putih
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Warna latar belakang aksen pink
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
    _timer.cancel();
    _stopNotificationSound();
    super.dispose();
  }
}
