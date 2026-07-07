import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/note_repository.dart';
import 'services/ai_settings.dart';
import 'services/ollama_service.dart';
import 'services/rag_service.dart';
import 'services/theme_settings.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = NoteRepository();
  await repo.load();
  final aiSettings = AiSettings();
  await aiSettings.load();
  final themeSettings = ThemeSettings();
  await themeSettings.load();
  final ollama = OllamaService(settings: aiSettings);
  final rag = RagService(repo: repo, ollama: ollama);
  runApp(MindVaultApp(
    repo: repo,
    aiSettings: aiSettings,
    themeSettings: themeSettings,
    ollama: ollama,
    rag: rag,
  ));
}

class MindVaultApp extends StatelessWidget {
  final NoteRepository repo;
  final AiSettings aiSettings;
  final ThemeSettings themeSettings;
  final OllamaService ollama;
  final RagService rag;

  const MindVaultApp({
    super.key,
    required this.repo,
    required this.aiSettings,
    required this.themeSettings,
    required this.ollama,
    required this.rag,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: repo),
        ChangeNotifierProvider.value(value: aiSettings),
        ChangeNotifierProvider.value(value: themeSettings),
        Provider.value(value: ollama),
        Provider.value(value: rag),
      ],
      child: Consumer<ThemeSettings>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'MindVault',
            debugShowCheckedModeBanner: false,
            themeMode: theme.mode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF00B894)),
              pageTransitionsTheme: const PageTransitionsTheme(builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              }),
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
          );
        },
      ),
    );
  }
}
