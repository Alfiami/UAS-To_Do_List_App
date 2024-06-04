import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MyPlayer extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();

  void playLocal() async {
    int result = await audioPlayer.play('assets/audio/audio.mp3', isLocal: true);
    if (result == 1) {
      // success
      print('Audio played');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Audio Player'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: playLocal,
          child: Text('Play Local Audio'),
        ),
      ),
    );
  }
}
