import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../services/category_data.dart';
import '../widgets/category_picker.dart';

/// Thêm giao dịch mới, hoặc sửa nếu [existing] được truyền vào.
class AddTransactionScreen extends StatefulWidget {
  final Transaction? existing;

  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TxType _type;
  late DateTime _date;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? TxType.expense;
    _date = e?.date ?? DateTime.now();
    _categoryId = e?.categoryId ?? CategoryData.byType(_type).first.id;
    if (e != null) {
      _amountController.text = e.amount.round().toString();
      _noteController.text = e.note;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TxType type) {
    setState(() {
      _type = type;
      final list = CategoryData.byType(type);
      if (!list.any((c) => c.id == _categoryId)) {
        _categoryId = list.first.id;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final provider = context.read<TransactionProvider>();

    if (widget.existing != null) {
      await provider.updateTransaction(
        widget.existing!.copyWith(
          amount: amount,
          categoryId: _categoryId,
          type: _type,
          date: _date,
          note: _noteController.text.trim(),
        ),
      );
    } else {
      await provider.addTransaction(
        amount: amount,
        categoryId: _categoryId!,
        type: _type,
        date: _date,
        note: _noteController.text.trim(),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryData.byType(_type);
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TxType>(
              segments: const [
                ButtonSegment(value: TxType.expense, label: Text('Chi tiêu')),
                ButtonSegment(value: TxType.income, label: Text('Thu nhập')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => _onTypeChanged(s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              decoration: const InputDecoration(
                labelText: 'Số tiền (VNĐ)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nhập số tiền';
                final n = double.tryParse(v.replaceAll(',', ''));
                if (n == null || n <= 0) return 'Số tiền không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Danh mục',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CategoryPicker(
              categories: categories,
              selectedId: _categoryId,
              onSelected: (id) => setState(() => _categoryId = id),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Ngày'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm giao dịch'),
            ),
          ],
        ),
      ),
    );
  }
}
