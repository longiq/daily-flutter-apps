import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'models.dart';
import 'storage.dart';
import 'study_screen.dart';

void main() {
  runApp(const FlashGenApp());
}

class FlashGenApp extends StatelessWidget {
  const FlashGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashGen AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int freeDeckLimit = 5; // Gói free: tối đa 5 bộ thẻ.

  final DeckStorage _storage = DeckStorage();
  final AiService _ai = AiService();

  List<Deck> _decks = [];
  bool _loading = true;
  bool _isPremium = false; // TODO: nối với in-app purchase thực tế.

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final decks = await _storage.load();
    setState(() {
      _decks = decks;
      _loading = false;
    });
  }

  Future<void> _persist() => _storage.save(_decks);

  Future<void> _openGenerator() async {
    if (!_isPremium && _decks.length >= freeDeckLimit) {
      _showPremiumDialog();
      return;
    }
    final result = await showDialog<_GenResult>(
      context: context,
      builder: (_) => const _GeneratorDialog(),
    );
    if (result == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final cards = await _ai.generate(result.text, count: result.count);

    if (!mounted) return;
    Navigator.of(context).pop(); // đóng loading

    final deck = Deck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: result.title.isEmpty ? 'Bộ thẻ mới' : result.title,
      cards: cards,
      createdAt: DateTime.now(),
    );
    setState(() => _decks.insert(0, deck));
    await _persist();
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đã đạt giới hạn gói Free'),
        content: const Text(
            'Gói Free cho phép tối đa $freeDeckLimit bộ thẻ.\n'
            'Nâng cấp Premium để tạo không giới hạn + xuất thẻ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: gọi flow mua IAP. Tạm bật premium để demo.
              setState(() => _isPremium = true);
              Navigator.pop(context);
            },
            child: const Text('Nâng cấp (demo)'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDeck(int index) async {
    setState(() => _decks.removeAt(index));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashGen AI'),
        actions: [
          if (_isPremium)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Chip(label: Text('PRO')),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openGenerator,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Tạo thẻ AI'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _decks.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style, size: 72, color: Colors.indigo),
            const SizedBox(height: 16),
            Text('Chưa có bộ thẻ nào',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Dán ghi chú/bài học, AI sẽ sinh flashcard tự động.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _decks.length,
      itemBuilder: (context, i) {
        final d = _decks[i];
        return Dismissible(
          key: ValueKey(d.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _deleteDeck(i),
          child: ListTile(
            leading: CircleAvatar(child: Text('${d.cards.length}')),
            title: Text(d.title),
            subtitle: Text('${d.cards.length} thẻ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (d.cards.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudyScreen(deck: d),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GenResult {
  final String title;
  final String text;
  final int count;
  _GenResult(this.title, this.text, this.count);
}

class _GeneratorDialog extends StatefulWidget {
  const _GeneratorDialog();

  @override
  State<_GeneratorDialog> createState() => _GeneratorDialogState();
}

class _GeneratorDialogState extends State<_GeneratorDialog> {
  final _titleCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  double _count = 8;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo flashcard bằng AI'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên bộ thẻ',
                hintText: 'VD: Lịch sử lớp 12 - Chương 1',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textCtrl,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Nội dung / ghi chú',
                hintText: 'Dán đoạn văn bản cần học...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Số thẻ:'),
                Expanded(
                  child: Slider(
                    value: _count,
                    min: 3,
                    max: 15,
                    divisions: 12,
                    label: '${_count.round()}',
                    onChanged: (v) => setState(() => _count = v),
                  ),
                ),
                Text('${_count.round()}'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: () {
            if (_textCtrl.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              _GenResult(
                _titleCtrl.text.trim(),
                _textCtrl.text.trim(),
                _count.round(),
              ),
            );
          },
          child: const Text('Sinh thẻ'),
        ),
      ],
    );
  }
}
