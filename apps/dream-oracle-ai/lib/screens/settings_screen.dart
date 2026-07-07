import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/ollama_service.dart';

/// Cấu hình Ollama (host/model), chế độ offline, dark mode.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _hostCtrl;
  late TextEditingController _modelCtrl;
  bool _testing = false;
  bool? _testResult;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _hostCtrl = TextEditingController(text: settings.host);
    _modelCtrl = TextEditingController(text: settings.model);
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final ok = await OllamaService(
      baseUrl: _hostCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
    ).testConnection();
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testResult = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Cấu hình Ollama (AI local)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Cài Ollama tại ollama.com, chạy "ollama pull llama3.2" rồi '
            '"ollama serve". Trên Android emulator dùng host 10.0.2.2.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hostCtrl,
            decoration: const InputDecoration(labelText: 'Host'),
            onChanged: (v) => context.read<SettingsProvider>().updateHost(v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modelCtrl,
            decoration: const InputDecoration(labelText: 'Model'),
            onChanged: (v) => context.read<SettingsProvider>().updateModel(v),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _testing ? null : _testConnection,
            icon: _testing
                ? const SizedBox(
                    width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.wifi_tethering),
            label: Text(_testing ? 'Đang kiểm tra...' : 'Kiểm tra kết nối'),
          ),
          if (_testResult != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    _testResult! ? Icons.check_circle : Icons.error,
                    color: _testResult! ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(_testResult!
                      ? 'Kết nối Ollama thành công!'
                      : 'Không kết nối được. Kiểm tra Ollama đã chạy chưa.'),
                ],
              ),
            ),
          const Divider(height: 32),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Luôn dùng chế độ offline'),
            subtitle: const Text('Bỏ qua Ollama, chỉ dùng từ điển biểu tượng.'),
            value: settings.forceOffline,
            onChanged: (v) => context.read<SettingsProvider>().setForceOffline(v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Giao diện tối (Dark mode)'),
            value: settings.darkMode,
            onChanged: (v) => context.read<SettingsProvider>().setDarkMode(v),
          ),
          const Divider(height: 32),
          Text('Về app', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Dream Oracle AI v1.0.0 — nhật ký giấc mơ + diễn giải biểu tượng. '
            'Diễn giải mang tính tham khảo/giải trí, không phải tư vấn y khoa/tâm lý.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
