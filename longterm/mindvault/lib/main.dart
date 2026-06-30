import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/note_repository.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = NoteRepository();
  await repo.load();
  runApp(MindVaultApp(repo: repo));
}

class MindVaultApp extends StatelessWidget {
  final NoteRepository repo;
  const MindVaultApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: repo,
      child: MaterialApp(
        title: 'MindVault',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B894)),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00B894),
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
