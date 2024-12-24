class AlarmSound {
  final String name;
  final String assetPath;

  AlarmSound({required this.name, required this.assetPath});

  static List<AlarmSound> defaultSounds = [
    AlarmSound(
      name: 'Classic Beep',
      assetPath: 'assets/sounds/alarm.mp3'
    ),
   
  ];
} 