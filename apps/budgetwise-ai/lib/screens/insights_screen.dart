import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/offline_insights.dart';
import '../services/ollama_service.dart';
import '../widgets/empty_state.dart';

/// Tab "AI": nhận xét/gợi ý tiết kiệm dựa trên quy tắc (luôn có, offline)
/// + tùy chọn phân tích chuyên sâu hơn bằng Ollama (giới hạn lượt miễn phí,
/// không giới hạn nếu Premium).
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _loadingAi = false;
  String? _aiResult;
  String? _aiError;

  Future<void> _runAiAnalysis(
    TransactionProvider txProvider,
    SettingsProvider settings,
  ) async {
    if (!settings.canUseAi) {
      setState(() {
        _aiError =
            'Bạn đã dùng hết ${SettingsProvider.freeAiLimitPerMonth} lượt phân '
                'tích AI miễn phí trong tháng. Nâng cấp Premium ở Cài đặt để '
                'dùng không giới hạn.';
        _aiResult = null;
      });
      return;
    }
    setState(() {
      _loadingAi = true;
      _aiError = null;
      _aiResult = null;
    });

    final summary = OfflineInsights.buildSummary(
      monthTx: txProvider.currentMonthTx,
      budgets: txProvider.budgets,
    );

    String? result;
    if (settings.ollamaEnabled) {
      final service = OllamaService(
        baseUrl: settings.ollamaHost,
        model: settings.ollamaModel,
      );
      result = await service.analyzeSpending(summary);
    }

    if (!settings.isPremium) {
      await settings.recordAiUse();
    }

    if (!mounted) return;
    setState(() {
      _loadingAi = false;
      if (result != null) {
        _aiResult = result;
      } else {
        _aiError =
            'Không kết nối được Ollama (chưa bật `ollama serve` hoặc chưa cấu '
                'hình đúng ở Cài đặt). Đây vẫn là những gợi ý cơ bản dựa trên '
                'số liệu chi tiêu của bạn phía dưới.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, SettingsProvider>(
      builder: (context, txProvider, settings, _) {
        if (!txProvider.loaded || !settings.loaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final ruleInsights = OfflineInsights.generate(
          currentMonthTx: txProvider.currentMonthTx,
          prevMonthTx: txProvider.previousMonthTx,
          budgets: txProvider.budgets,
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Phân tích chuyên sâu bằng AI',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      settings.isPremium
                          ? 'Premium: không giới hạn lượt phân tích.'
                          : 'Còn ${settings.remainingFreeAi}/'
                              '${SettingsProvider.freeAiLimitPerMonth} lượt miễn phí '
                              'tháng này.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    if (_loadingAi)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _runAiAnalysis(txProvider, settings),
                          icon: const Icon(Icons.psychology_outlined),
                          label: Text(
                            _aiResult == null && _aiError == null
                                ? 'Phân tích ngay'
                                : 'Phân tích lại',
                          ),
                        ),
                      ),
                    if (_aiResult != null) ...[
                      const SizedBox(height: 12),
                      Text(_aiResult!),
                    ],
                    if (_aiError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _aiError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nhận xét nhanh',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (ruleInsights.isEmpty)
              const EmptyState(
                icon: Icons.insights_outlined,
                title: 'Chưa đủ dữ liệu',
                subtitle: 'Thêm giao dịch để xem nhận xét chi tiêu.',
              )
            else
              ...ruleInsights.map(
                (text) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: Text(text),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
