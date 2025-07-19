import 'package:flutter/material.dart';
import '../services/journal_service.dart';
import '../widgets/journal_app_bar.dart';
import '../widgets/journal_bottom_sheet.dart';
import '../widgets/journal_list_view.dart';
import '../widgets/journal_floating_button.dart';
import 'fullscreen_editor.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  void _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _journalService.addEntry(text);
    _controller.clear();
    setState(() => _isComposing = false);
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 65, 4, 70),
      appBar: JournalAppBar(
        onMenuPressed: () {},
      ),
      body: JournalListView(
        scrollController: _scrollController,
        journalService: _journalService,
      ),
      floatingActionButton: JournalFloatingButton(
        onPressed: _scrollToTop,
      ),
      bottomSheet: JournalBottomSheet(
        controller: _controller,
        isComposing: _isComposing,
        onChanged: (text) =>
            setState(() => _isComposing = text.trim().isNotEmpty),
        onSubmit: _submit,
        onClear: () {
          _controller.clear();
          setState(() => _isComposing = false);
          FocusScope.of(context).unfocus();
        },
        onAddPressed: _showFullScreenEditor, 
      ),
    );
  }

  Future<void> _showFullScreenEditor() async {
    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => FullScreenEditor(
          controller: _controller,
          onSubmit: _submit,
        ),
      );
    } catch (e) {
      debugPrint('Failed to show editor: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open editor')),
        );
      }
    }
  }
}
