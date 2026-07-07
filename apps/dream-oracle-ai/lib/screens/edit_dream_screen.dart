import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dream_provider.dart';
import '../widgets/mood_picker.dart';
import 'interpretation_screen.dart';

/// Ghi lại giấc mơ mới: tiêu đề, nội dung, mood, tags.
class EditDreamScreen extends StatefulWidget {
  const EditDreamScreen({super.key});

  @override
  State<EditDreamScreen> createState() => _EditDreamScreenState();
}

class _EditDreamScreenState extends State<EditDreamScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  String _mood = '😐';
  final List<String> _tags = [];
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy mô tả giấc mơ của bạn trước đã.')),
      );
      return;
    }
    setState(() => _saving = true);
    final entry = await context.read<DreamProvider>().addDream(
          title: _titleCtrl.text,
          content: _contentCtrl.text,
          moodEmoji: _mood,
          tags: _tags,
        );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => InterpretationScreen(dreamId: entry.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ghi giấc mơ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tiêu đề', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Vd: Bay qua thành phố'),
            ),
            const SizedBox(height: 16),
            const Text('Bạn đã mơ thấy gì?',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText:
                    'Mô tả càng chi tiết càng giúp diễn giải chính xác hơn: '
                    'nhân vật, địa điểm, cảm xúc, sự việc xảy ra...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Cảm xúc khi tỉnh dậy',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            MoodPicker(selected: _mood, onChanged: (m) => setState(() => _mood = m)),
            const SizedBox(height: 16),
            const Text('Tags (tuỳ chọn)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(hintText: 'Vd: ác mộng, lặp lại'),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.add_circle), onPressed: _addTag),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags
                    .map((t) => Chip(
                          label: Text(t),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_saving ? 'Đang lưu...' : 'Lưu & Diễn giải'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
