import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_settings.dart';
import '../services/ollama_service.dart';
import '../services/theme_settings.dart';

/// Cài đặt kết nối Ollama: host, tên model, bật/tắt AI, kiểm tra kết nối.
/// Kèm phần "Giao diện" để đổi sáng/tối/theo hệ thống (M5).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _host;
  late final TextEditingController _model;
  bool? _testResult; // null = chưa test

  @override
  void initState() {
    super.initState();
    final settings = context.read<AiSettings>();
    _host = TextEditingController(text: settings.host);
    _model = TextEditingController(text: settings.model);
  }

  @override
  void dispose() {
    _host.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context
        .read<AiSettings>()
        .update(host: _host.text, model: _model.text);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã lưu cài đặt AI.')));
    }
  }

  Future<void> _testConnection() async {
    await _save();
    setState(() => _testResult = null);
    final ollama = context.read<OllamaService>();
    final ok = await ollama.isAvailable();
    if (mounted) setState(() => _testResult = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiSettings>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Cài đặt')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Giao diện', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Consumer<ThemeSettings>(
                builder: (context, themeSettings, _) {
                  return SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('Hệ thống'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Sáng'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Tối'),
                      ),
                    ],
                    selected: {themeSettings.mode},
                    onSelectionChanged: (modes) =>
                        themeSettings.setMode(modes.first),
                  );
                },
              ),
              const Divider(height: 32),
              Text('AI (Ollama)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Bật AI (Ollama)'),
                subtitle: const Text(
                    'Tắt thì app luôn dùng tóm tắt/trả lời offline'),
                value: settings.enabled,
                onChanged: (v) =>
                    context.read<AiSettings>().update(enabled: v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _host,
                decoration: const InputDecoration(
                  labelText: 'Ollama host',
                  hintText: 'http://localhost:11434',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _model,
                decoration: const InputDecoration(
                  labelText: 'Tên model',
                  hintText: 'llama3.2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(onPressed: _save, child: const Text('Lưu')),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _testConnection,
                    child: const Text('Kiểm tra kết nối'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_testResult != null)
                Row(
                  children: [
                    Icon(
                      _testResult! ? Icons.check_circle : Icons.error,
                      color: _testResult! ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_testResult!
                          ? 'Kết nối Ollama OK'
                          : 'Không kết nối được. App sẽ dùng chế độ offline.'),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Text(
                'Chạy Ollama trên Mac mini: "ollama serve" rồi '
                '"ollama pull ${settings.model}". Nếu tắt Ollama hoặc '
                'offline, MindVault tự chuyển sang tóm tắt/trả lời offline '
                'đơn giản (không cần mạng).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
