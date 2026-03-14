import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pillmate_college/screens/profile_screen.dart';
import 'notification_service.dart';

class NotificationPermissionUIScreen extends StatefulWidget {
  const NotificationPermissionUIScreen({super.key});

  @override
  State<NotificationPermissionUIScreen> createState() =>
      _NotificationPermissionUIScreenState();
}

class _NotificationPermissionUIScreenState
    extends State<NotificationPermissionUIScreen>
    with TickerProviderStateMixin {

  final List<Map<String, String>> sounds = [
    {'id': 'alarm', 'label': 'Alarm', 'emoji': '⏰'},
    {'id': 'alert', 'label': 'Alert', 'emoji': '🚨'},
    {'id': 'funny', 'label': 'Funny', 'emoji': '😄'},
    {'id': 'just_do_it', 'label': 'Just Do It', 'emoji': '💪'},
    {'id': 'notification', 'label': 'Notification', 'emoji': '🔔'},
    {'id': 'notify', 'label': 'Notify', 'emoji': '✨'},
    {'id': 'soft', 'label': 'Soft', 'emoji': '🌸'},
  ];

  String _selectedSoundId = 'notification';
  String? _playingId;
  bool _isSaving = false;

  final AudioPlayer _player = AudioPlayer();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() => _playingId = null);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _previewSound(String soundId) async {
    try {
      await _player.stop();

      if (_playingId == soundId) {
        setState(() => _playingId = null);
        return;
      }

      setState(() => _playingId = soundId);

      await _player.play(
        AssetSource('sounds/$soundId.mp3'),
        volume: 1.0,
      );

    } catch (e) {
      debugPrint("Sound error: $e");
      setState(() => _playingId = null);
    }
  }

  Future<void> _allowAndContinue() async {
    setState(() => _isSaving = true);

    await _player.stop();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_sound', _selectedSoundId);

    await NotificationService.initWithSound(_selectedSoundId);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  Widget _soundTile(Map<String, String> sound) {
    final isSelected = _selectedSoundId == sound['id'];
    final isPlaying = _playingId == sound['id'];

    return GestureDetector(
      onTap: () {
        setState(() => _selectedSoundId = sound['id']!);
        _previewSound(sound['id']!);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4C8CFF).withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4C8CFF)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [

            Text(
              sound['emoji']!,
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                sound['label']!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF4C8CFF)
                      : Colors.black87,
                ),
              ),
            ),

            if (isSelected && !isPlaying)
              const Icon(Icons.check_circle,
                  color: Color(0xFF4C8CFF), size: 20),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: () => _previewSound(sound['id']!),
              child: isPlaying
                  ? ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4C8CFF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4C8CFF).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(Icons.stop,
                      color: Colors.white),
                ),
              )
                  : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                  const Color(0xFF4C8CFF).withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFF4C8CFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            children: [

              const SizedBox(height: 16),

              Image.asset(
                'assets/images/img_11.png',
                height: 150,
              ),

              const SizedBox(height: 20),

              const Text(
                "Never miss a dose",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Pick a reminder sound, then allow notifications.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Text(
                    "Choose your sound",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const Spacer(),
                  Icon(Icons.touch_app_outlined,
                      size: 14,
                      color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    "tap to preview",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400]),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: sounds.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _soundTile(sounds[index]),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                  _isSaving ? null : _allowAndContinue,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF4C8CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),

                  child: _isSaving
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text(
                    "Allow Notifications",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                        const ProfileScreen()),
                  );
                },
                child: const Text(
                  "Maybe later",
                  style: TextStyle(
                      color: Color(0xFF4C8CFF)),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}