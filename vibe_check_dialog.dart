import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class VibeCheckDialog extends StatefulWidget {
  final ValueChanged<String> onConfirm;
  const VibeCheckDialog({super.key, required this.onConfirm});

  @override
  State<VibeCheckDialog> createState() => _VibeCheckDialogState();
}

class _VibeCheckDialogState extends State<VibeCheckDialog>
    with SingleTickerProviderStateMixin {
  // Organized emojis by mood categories
  static const Map<String, List<String>> _emojiCategories = {
    'Positive': ['😃', '🥰', '😎', '🥳'],
    'Neutral': ['🙂', '😐'],
    'Negative': ['😔', '😢', '😭', '😡'],
    'Physical': ['🤢', '💀'],
  };

  static const Map<String, String> _vibeMessages = {
    '😃': 'Love that energy—keep smiling and sharing your light!',
    '🙂': 'You\'re doing great—enjoy this steady stride!',
    '😐': 'Every day\'s a fresh page—let\'s write something awesome!',
    '😔': 'Even small steps matter—tomorrow you\'ll feel stronger.',
    '😢': 'It\'s okay to feel—embrace the moment and be gentle with yourself.',
    '😭': 'Strength grows through storms—brighter days are coming.',
    '🥰': 'Your kindness makes the world better—pass it on!',
    '😎': 'Keep that confidence rolling—nothing can stop you now!',
    '🥳': 'Celebrate this win—here\'s to many more!',
    '😡': 'Channel that fire into fuel—let it drive you forward!',
    '🤢': 'Listen to your body—take a breather and reset.',
    '💀': 'Rest is just as important as hustle—recharge and return!',
  };

  String? _selectedEmoji;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleEmojiSelection(String emoji) {
    setState(() {
      _selectedEmoji = emoji;
    });
    HapticFeedback.lightImpact();
  }

  void _confirmSelection() async {
    if (_selectedEmoji == null) return;

    final emoji = _selectedEmoji!;
    widget.onConfirm(emoji);

    await _controller.reverse();

    if (!mounted) return;

    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 200));

    if (context.mounted) {
      _showFollowUpMessage(emoji);
    }
  }

  void _showFollowUpMessage(String emoji) {
    final message = _vibeMessages[emoji] ?? "You're doing great!";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('GOT IT'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select an emoji that matches your vibe',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.lerp(onSurface, surface, 0.3),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Emoji categories
                for (final category in _emojiCategories.entries) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          category.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color.lerp(onSurface, surface, 0.2),
                          ),
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: category.value.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          for (final emoji in category.value)
                            GestureDetector(
                              onTap: () => _handleEmojiSelection(emoji),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: emoji == _selectedEmoji
                                      ? theme.primaryColor.withAlpha(25)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: emoji == _selectedEmoji
                                        ? theme.primaryColor
                                        : Colors.grey.withAlpha(76),
                                    width: emoji == _selectedEmoji ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: AnimatedScale(
                                    scale: emoji == _selectedEmoji ? 1.3 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(emoji,
                                        style: const TextStyle(fontSize: 28)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Color.lerp(onSurface, surface, 0.3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Not Now'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed:
                            _selectedEmoji == null ? null : _confirmSelection,
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
