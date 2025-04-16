import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class NotifyRide extends StatefulWidget {
  const NotifyRide({super.key});

  @override
  State<NotifyRide> createState() => _NotifyRideState();
}

class _NotifyRideState extends State<NotifyRide> {
 late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer
        .dispose(); // Libérer les ressources audio lorsque le widget est détruit
  }

  // Fonction pour lire le son
  void _playSound() async {
    await _audioPlayer.play(
      AssetSource(
        'assets/notification_sound.mp3',
      ), // Utilisation de AssetSource ici
      volume: 1.0, // Volume à 100%
      mode: PlayerMode.mediaPlayer, // Mode de lecture (par défaut)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Player Example')),
      body: Center(
        child: ElevatedButton(
          onPressed:
              _playSound, // Jouer le son quand l'utilisateur appuie sur le bouton
          child: Text('Play Sound'),
        ),
      ),
    );

  }
}