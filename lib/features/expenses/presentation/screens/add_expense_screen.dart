import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';

/// Form screen for recording food expenses with keyboard-safe scrolling.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  static const List<String> _categories = [
    'Groceries', 'Dining Out', 'Kitchen Tools', 'Spices', 'Delivery',
  ];

  String _selectedCategory = 'Groceries';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Title / Description',
                    hintText: 'e.g. Weekly Farmers Market',
                    prefixIcon: const Icon(Icons.receipt_long_outlined),
                    border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a description' : null,
                ),
                AppSpacing.gapH16,
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (\$)',
                    hintText: '0.00',
                    prefixText: '\$ ',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                    final amt = double.tryParse(val.trim());
                    return (amt == null || amt <= 0) ? 'Enter a valid amount > 0' : null;
                  },
                ),
                AppSpacing.gapH16,
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
                  ),
                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                AppSpacing.gapH16,
                InkWell(
                  onTap: _pickDate,
                  borderRadius: AppBorderRadius.r12,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expense Date',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
                    ),
                    child: Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: getRegularStyle(context: context, fontSize: FontSize.s14),
                    ),
                  ),
                ),
                AppSpacing.gapH32,
                AppButton(text: 'Save Expense', onPressed: _saveExpense),
                AppSpacing.gapH12,
                AppButton(text: 'Cancel', isOutlined: true, onPressed: () => Navigator.of(context).pop()),
                AppSpacing.gapH24,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveExpense() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'category': _selectedCategory,
        'date': _selectedDate,
      });
    }
  }
}
