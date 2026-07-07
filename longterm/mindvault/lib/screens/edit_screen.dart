import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/auto_tagger.dart';
import '../services/note_repository.dart';
import '../services/offline_ai.dart';
import '../services/ollama_service.dart';
import '../widgets/tag_chip_input.dart';

/// Màn thêm/sửa ghi chú. Truyền [note] null = tạo mới.
class EditScreen extends StatefulWidget {
  final Note? note;
  const EditScreen({super.key, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late List<String> _tagList;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note?.title ?? '');
    _body = TextEditingController(text: widget.note?.body ?? '');
    _tagList = List<String>.from(widget.note?.tags ?? const []);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = context.read<NoteRepository>();
    final note = (widget.note ??
            Note(
              id: NoteRepository.newId(),
              title: '',
              body: '',
              updatedAt: DateTime.now(),
            ))
        .copyWith(
      title: _title.text,
      body: _body.text,
      tags: _tagList,
      updatedAt: DateTime.now(),
    );
    await repo.save(note);
    if (mounted) Navigator.pop(context);
  }

  /// Tóm tắt nội dung đang soạn bằng Ollama; nếu không kết nối được thì tự
  /// chuyển sang tóm tắt offline (trích câu quan trọng, không cần mạng).
  Future<void> _summarize() async {
    final body = _body.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có nội dung để tóm tắt.')),
      );
      return;
    }
    final ollama = context.read<OllamaService>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
    var result = await ollama.summarize(_title.text, body);
    if (!result.fromOllama) {
      result = AiResult(
        text: OfflineAi.summarize(body),
        fromOllama: false,
        error: result.error,
      );
    }
    if (!mounted) return;
    Navigator.pop(context); // đóng dialog loading
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.fromOllama ? Icons.auto_awesome : Icons.wifi_off,
              size: 18,
              color: result.fromOllama ? Colors.teal : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(result.fromOllama ? 'Tóm tắt (Ollama)' : 'Tóm tắt (offline)'),
          ],
        ),
        content: Text(result.text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Gợi ý tag dựa trên nội dung đang soạn: thử Ollama trước, nếu không có
  /// thì dùng [AutoTagger.offlineSuggest] (từ điển chủ đề + tần suất từ,
  /// không cần mạng). Hiện danh sách gợi ý để người dùng bấm thêm dần.
  Future<void> _suggestTags() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có nội dung để gợi ý tag.')),
      );
      return;
    }
    final ollama = context.read<OllamaService>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
    List<String> suggestions;
    bool fromOllama;
    final ollamaResult = await AutoTagger.ollamaSuggest(ollama, title, body);
    if (ollamaResult.fromOllama) {
      suggestions = AutoTagger.parseTagsResponse(ollamaResult.text)
          .where((t) => !_tagList.contains(t))
          .toList();
      fromOllama = true;
    } else {
      suggestions = [];
      fromOllama = false;
    }
    if (suggestions.isEmpty) {
      suggestions = AutoTagger.offlineSuggest(title, body,
          existingTags: _tagList);
      fromOllama = false;
    }
    if (!mounted) return;
    Navigator.pop(context); // đóng dialog loading

    if (suggestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm được gợi ý tag phù hợp.')),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          fromOllama ? Icons.auto_awesome : Icons.wifi_off,
                          size: 18,
                          color: fromOllama ? Colors.teal : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fromOllama
                              ? 'Gợi ý tag (Ollama)'
                              : 'Gợi ý tag (offline)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions.map((tag) {
                        final added = _tagList.contains(tag);
                        return ActionChip(
                          avatar: Icon(
                              added ? Icons.check : Icons.add,
                              size: 16),
                          label: Text(tag),
                          onPressed: added
                              ? null
                              : () {
                                  setState(() => _tagList = [
                                        ..._tagList,
                                        tag
                                      ]);
                                  setSheetState(() {});
                                },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Xong'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.note == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Ghi chú mới' : 'Sửa ghi chú'),
        actions: [
          IconButton(
            tooltip: 'Tóm tắt AI',
            icon: const Icon(Icons.auto_awesome),
            onPressed: _summarize,
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: 'Tiêu đề', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TagChipInput(
                    tags: _tagList,
                    onChanged: (t) => setState(() => _tagList = t),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Gợi ý tag',
                  icon: const Icon(Icons.sell_outlined),
                  onPressed: _suggestTags,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _body,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
