import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/ollama_service.dart';

/// Cài đặt: giao diện, cấu hình Ollama, Premium (mô phỏng mua hàng),
/// và xóa toàn bộ dữ liệu.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _hostController;
  late TextEditingController _modelController;
  bool? _testResult;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _hostController = TextEditingController(text: settings.ollamaHost);
    _modelController = TextEditingController(text: settings.ollamaModel);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _saveOllamaConfig(SettingsProvider settings) async {
    await settings.setOllamaConfig(
      host: _hostController.text.trim(),
      model: _modelController.text.trim(),
      enabled: settings.ollamaEnabled,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cấu hình Ollama')),
      );
    }
  }

  Future<void> _testConnection(SettingsProvider settings) async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final service = OllamaService(
      baseUrl: _hostController.text.trim(),
      model: _modelController.text.trim(),
    );
    final ok = await service.testConnection();
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testResult = ok;
    });
  }

  Future<void> _confirmReset(TransactionProvider txProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ dữ liệu?'),
        content: const Text(
          'Toàn bộ giao dịch và ngân sách đã lưu sẽ bị xóa vĩnh viễn. '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    for (final t in List.of(txProvider.all)) {
      await txProvider.deleteTransaction(t.id);
    }
    for (final b in List.of(txProvider.budgets)) {
      await txProvider.removeBudget(b.categoryId);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, TransactionProvider>(
      builder: (context, settings, txProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Cài đặt')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionTitle('Giao diện'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Chế độ tối'),
                value: settings.darkMode,
                onChanged: settings.setDarkMode,
              ),
              const Divider(height: 32),
              _SectionTitle('Premium'),
              Card(
                child: SwitchListTile(
                  title: const Text('Premium (mô phỏng)'),
                  subtitle: Text(
                    settings.isPremium
                        ? 'Đã mở khóa: phân tích AI không giới hạn.'
                        : 'Mở khóa phân tích AI không giới hạn + gỡ quảng cáo.',
                  ),
                  value: settings.isPremium,
                  onChanged: settings.setPremium,
                ),
              ),
              const Divider(height: 32),
              _SectionTitle('Ollama (AI local)'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bật phân tích AI qua Ollama'),
                value: settings.ollamaEnabled,
                onChanged: (v) => settings.setOllamaConfig(
                  host: _hostController.text.trim(),
                  model: _modelController.text.trim(),
                  enabled: v,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ Ollama',
                  hintText: 'http://localhost:11434',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Tên model',
                  hintText: 'llama3.2',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveOllamaConfig(settings),
                      child: const Text('Lưu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _testing ? null : () => _testConnection(settings),
                      child: _testing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kiểm tra kết nối'),
                    ),
                  ),
                ],
              ),
              if (_testResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _testResult!
                        ? 'Kết nối Ollama thành công!'
                        : 'Không kết nối được — kiểm tra Ollama đã chạy '
                            '(`ollama serve`) và địa chỉ đúng chưa.',
                    style: TextStyle(
                      color: _testResult!
                          ? const Color(0xFF00B894)
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const Divider(height: 32),
              _SectionTitle('Dữ liệu'),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text('Xóa toàn bộ dữ liệu'),
                  onTap: () => _confirmReset(txProvider),
                ),
              ),
              const Divider(height: 32),
              _SectionTitle('Về ứng dụng'),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text('BudgetWise AI v1.0.0'),
                subtitle: Text(
                  'Quản lý thu chi cá nhân + AI phân tích chi tiêu qua Ollama '
                  'local. Dữ liệu lưu hoàn toàn trên máy, không gửi lên server '
                  'nào ngoài Ollama do bạn tự cấu hình.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
