import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_repository.dart';
import '../utils/page_transitions.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/note_card.dart';
import '../widgets/tag_filter_bar.dart';
import 'ask_screen.dart';
import 'edit_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  final Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindVault'),
        actions: [
          IconButton(
            tooltip: 'Hỏi vault của bạn',
            icon: const Icon(Icons.forum_outlined),
            onPressed: () => Navigator.push(
              context,
              fadeSlideTo((_) => const AskScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              fadeSlideTo((_) => const SettingsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<NoteRepository>(
        builder: (context, repo, _) {
          // Bỏ tag đã chọn nhưng không còn tồn tại nữa (vd. tag cuối cùng
          // của note đó vừa bị xóa) để tránh lọc "mất tích" gây rối.
          final allTags = repo.allTags;
          _selectedTags.removeWhere((t) => !allTags.contains(t));
          final notes = repo.search(_query, tags: _selectedTags);
          return Column(
            children: [
              if (allTags.isNotEmpty) ...[
                const SizedBox(height: 8),
                TagFilterBar(
                  allTags: allTags,
                  selected: _selectedTags,
                  onToggle: (tag) => setState(() {
                    if (!_selectedTags.remove(tag)) _selectedTags.add(tag);
                  }),
                  onClear: () => setState(_selectedTags.clear),
                ),
                const SizedBox(height: 4),
              ],
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Text(
                          _query.isEmpty && _selectedTags.isEmpty
                              ? 'Chưa có ghi chú. Bấm + để thêm.'
                              : 'Không tìm thấy ghi chú nào.',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notes.length,
                        itemBuilder: (context, i) {
                          final note = notes[i];
                          return FadeSlideIn(
                            key: ValueKey(note.id),
                            index: i,
                            child: NoteCard(
                              note: note,
                              onTap: () => Navigator.push(
                                context,
                                fadeSlideTo((_) => EditScreen(note: note)),
                              ),
                              onDelete: () => repo.delete(note.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          fadeSlideTo((_) => const EditScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
