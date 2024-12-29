import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/alarm_sound.dart';

class SoundSelectionDialog extends StatefulWidget {
  final AlarmSound? initialSound;

  SoundSelectionDialog({this.initialSound});

  @override
  _SoundSelectionDialogState createState() => _SoundSelectionDialogState();
}

class _SoundSelectionDialogState extends State<SoundSelectionDialog> {
  final AudioPlayer audioPlayer = AudioPlayer();
  AlarmSound? selectedSound;
  int? playingIndex;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    selectedSound = widget.initialSound ?? AlarmSound.defaultSounds[0];
    
    // Add error listener
    audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          playingIndex = null;
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String assetPath) async {
    try {
      setState(() {
        isPlaying = true;
      });
      
      await audioPlayer.stop();
      await audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (mounted) {
        setState(() {
          playingIndex = null;
          isPlaying = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to play sound preview'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Alarm Sound',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: AlarmSound.defaultSounds.length,
                itemBuilder: (context, index) {
                  final sound = AlarmSound.defaultSounds[index];
                  return ListTile(
                    title: Text(sound.name),
                    leading: Radio<AlarmSound>(
                      value: sound,
                      groupValue: selectedSound,
                      onChanged: (AlarmSound? value) {
                        setState(() {
                          selectedSound = value;
                        });
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        (playingIndex == index && isPlaying) 
                            ? Icons.stop 
                            : Icons.play_arrow,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          if (playingIndex == index && isPlaying) {
                            audioPlayer.stop();
                            playingIndex = null;
                            isPlaying = false;
                          } else {
                            playingIndex = index;
                            _playSound(sound.assetPath);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    audioPlayer.stop();
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    audioPlayer.stop();
                    Navigator.pop(context, selectedSound);
                  },
                  child: Text('Select'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFCCEA),
                    foregroundColor: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 