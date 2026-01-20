import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_data.dart';
import '../../../data/models/transaction_model.dart';
import '../controller/transaction_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '48.00');
  final _amountFocusNode = FocusNode();

  final TransactionController _controller = TransactionController();

  late String _selectedCategory;

  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedCategory = kCategories.first;
    _nameCtrl.text = _selectedCategory;
    _amountFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _amountFocusNode.removeListener(() {
      setState(() {});
    });
    _amountFocusNode.dispose();
    super.dispose();
  }

  String get _title => _isIncome ? 'Add Income' : 'Add Expense';

  Color get _primaryColor => _isIncome ? AppColors.primary : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        leading: const BackButton(color: Colors.white),
        title: Text(
          _title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_horiz, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _typeItem(
                    label: 'Expense',
                    selected: !_isIncome,
                    onTap: () => setState(() => _isIncome = false),
                  ),
                  _typeItem(
                    label: 'Income',
                    selected: _isIncome,
                    onTap: () => setState(() => _isIncome = true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('NAME'),
                  _inputBox(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        items: kCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Row(
                              children: [
                                kCategoryAvatars[category] ??
                                    const SizedBox.shrink(),
                                const SizedBox(width: 12),
                                Text(category),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                              _nameCtrl.text = newValue;
                            });
                          }
                        },
                        icon: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label('AMOUNT'),
                  _inputBox(
                    borderColor: _amountFocusNode.hasFocus
                        ? _primaryColor
                        : null,
                    child: Row(
                      children: [
                        Text(
                          '\$ ',
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _amountFocusNode,
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\\d*\\.?\\d{0,2}\$'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _amountCtrl.clear(),
                          child: Text(
                            'Clear',
                            style: TextStyle(color: _primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label('DATE'),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: _inputBox(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat(
                                'EEE, dd MMM yyyy',
                              ).format(_selectedDate),
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label('INVOICE'),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline),
                          SizedBox(width: 8),
                          Text('Add Invoice'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeItem({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _primaryColor : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    ),
  );

  Widget _inputBox({required Widget child, Color? borderColor}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: borderColor ?? Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  void _submit() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null) return;

    final tx = TransactionModel(
      id: const Uuid().v4(),
      title: _nameCtrl.text,
      amount: amount,
      date: _selectedDate,
      isIncome: _isIncome,
      category: _selectedCategory,
    );

    await _controller.addTransaction(tx);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
