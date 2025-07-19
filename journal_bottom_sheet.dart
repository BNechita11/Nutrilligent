import 'package:flutter/material.dart';

class JournalBottomSheet extends StatelessWidget {
  final TextEditingController controller;
  final bool isComposing;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final VoidCallback onAddPressed;

  const JournalBottomSheet({
    super.key,
    required this.controller,
    required this.isComposing,
    required this.onChanged,
    required this.onSubmit,
    required this.onClear,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isComposing)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'New Entry',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black12),
                    onPressed: onClear,
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    hintText: 'Write something motivating...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 253, 240, 240),
                    suffixIcon: isComposing
                        ? IconButton(
                            icon: Icon(
                              Icons.send,
                              color: colorScheme.primary,
                            ),
                            onPressed: onSubmit,
                          )
                        : null,
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
              if (!isComposing) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.black12),
                    onPressed: onAddPressed,
                  ),
                )
              ],
            ],
          ),
        ],
      ),
    );
  }
}