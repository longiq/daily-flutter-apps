import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_repository.dart';
import '../widgets/note_card.dart';
import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindVault'),
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
          final notes = repo.search(_query);
          if (notes.isEmpty) {
            return Center(
              child: Text(
                _query.isEmpty
                    ? 'Chưa có ghi chú. Bấm + để thêm.'
                    : 'Không tìm thấy ghi chú nào.',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notes.length,
            itemBuilder: (context, i) {
              final note = notes[i];
              return NoteCard(
                note: note,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditScreen(note: note)),
                ),
                onDelete: () => repo.delete(note.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
