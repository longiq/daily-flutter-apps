import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chunk.dart';
import '../services/note_repository.dart';
import '../services/rag_service.dart';
import '../utils/page_transitions.dart';
import '../widgets/fade_slide_in.dart';
import 'edit_screen.dart';

/// Màn "Hỏi vault của bạn": mini-RAG local, tìm đoạn ghi chú liên quan rồi
/// trả lời (Ollama nếu có, offline nếu không).
class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  AskResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _result = null;
    });
    final rag = context.read<RagService>();
    final result = await rag.ask(q);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hỏi vault của bạn')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'VD: mình ghi gì về Flutter provider?',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _ask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _loading ? null : _ask,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _loading
                    ? const Center(
                        key: ValueKey('loading'),
                        child: CircularProgressIndicator(),
                      )
                    : _result != null
                        ? KeyedSubtree(
                            key: ValueKey(_result!.answer),
                            child: _buildResult(_result!),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(AskResult result) {
    return ListView(
      children: [
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      result.fromOllama ? Icons.auto_awesome : Icons.wifi_off,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      result.fromOllama
                          ? 'Trả lời bằng Ollama'
                          : 'Trả lời offline',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(result.answer),
              ],
            ),
          ),
        ),
        if (result.sources.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Nguồn (${result.sources.length}):',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...result.sources.asMap().entries.map(
                (e) => FadeSlideIn(
                  index: e.key,
                  child: _SourceTile(scored: e.value),
                ),
              ),
        ],
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  final ScoredChunk scored;
  const _SourceTile({required this.scored});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<NoteRepository>();
    return Card(
      child: ListTile(
        dense: true,
        title: Text(scored.chunk.noteTitle.isEmpty
            ? '(Không tiêu đề)'
            : scored.chunk.noteTitle),
        subtitle:
            Text(scored.chunk.text, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(scored.score.toStringAsFixed(2)),
        onTap: () {
          final matches = repo.notes.where((n) => n.id == scored.chunk.noteId);
          if (matches.isNotEmpty) {
            Navigator.push(
              context,
              fadeSlideTo((_) => EditScreen(note: matches.first)),
            );
          }
        },
      ),
    );
  }
}
