import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';
import 'package:ocr_expense_tracker/core/utils/date_formatter.dart';
import 'package:ocr_expense_tracker/features/ocr/models/parsed_receipt.dart';
import 'package:ocr_expense_tracker/features/review/presentation/widgets/category_selector.dart';
import 'package:ocr_expense_tracker/features/review/presentation/widgets/receipt_header.dart';
import 'package:ocr_expense_tracker/features/review/presentation/widgets/review_form.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

// Màn hình kiểm tra và chỉnh sửa kết quả OCR hoặc cập nhật giao dịch đã lưu.
class ReviewScreen extends ConsumerStatefulWidget {
  final ParsedReceipt? parsedReceipt;
  final String? imagePath;
  final Expense? existingExpense;

  const ReviewScreen({
    super.key,
    this.parsedReceipt,
    this.imagePath,
    this.existingExpense,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final TextEditingController _merchantController;
  late final TextEditingController _dateController;
  late final TextEditingController _amountController;

  ExpenseCategory? _selectedCategory;
  String? _merchantError;
  String? _dateError;
  String? _amountError;
  String? _categoryError;
  bool _isSaving = false;

  String? get _effectiveImagePath =>
      widget.existingExpense?.thumbnailPath ??
      widget.parsedReceipt?.imagePath ??
      widget.imagePath;

  bool get _isEditMode => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final e = widget.existingExpense!;
      _merchantController = TextEditingController(text: e.merchant);
      final parsedDate = DateFormatter.parse(e.transactionDate);
      _dateController = TextEditingController(
        text: parsedDate != null ? DateFormatter.toDisplay(parsedDate) : e.transactionDate,
      );
      _amountController = TextEditingController(text: e.totalAmount.toString());
      _selectedCategory = e.category;
    } else {
      final receipt = widget.parsedReceipt;
      _merchantController = TextEditingController(text: receipt?.merchant ?? '');

      String dateText = '';
      if (receipt?.date != null && receipt!.date!.isNotEmpty) {
        final parsedDate = DateFormatter.parse(receipt.date!);
        dateText = parsedDate != null
            ? DateFormatter.toDisplay(parsedDate)
            : receipt.date!;
      }
      _dateController = TextEditingController(text: dateText);
      _amountController = TextEditingController(
        text: receipt?.totalAmount?.toString() ?? '',
      );
      _selectedCategory = receipt?.category;
    }
    _validateForm(silent: true);
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _validateForm({bool silent = false}) {
    String? mErr, dErr, aErr, cErr;
    final mText = _merchantController.text.trim();
    if (mText.isEmpty) mErr = 'Tên cửa hàng không được để trống';

    final dText = _dateController.text.trim();
    if (dText.isEmpty) {
      dErr = 'Ngày giao dịch không được để trống';
    } else if (DateFormatter.parse(dText) == null) {
      dErr = 'Ngày không hợp lệ (DD/MM/YYYY)';
    }

    final aText = _amountController.text.trim();
    final parsedAmount = CurrencyFormatter.parse(aText);
    if (parsedAmount == null || parsedAmount <= 0) {
      aErr = 'Số tiền phải lớn hơn 0';
    }

    if (_selectedCategory == null) {
      cErr = 'Vui lòng chọn danh mục chi tiêu';
    }

    if (!silent) {
      setState(() {
        _merchantError = mErr;
        _dateError = dErr;
        _amountError = aErr;
        _categoryError = cErr;
      });
    }

    return mErr == null && dErr == null && aErr == null && cErr == null;
  }


  Future<void> _selectDate() async {
    final current = DateFormatter.parse(_dateController.text.trim());
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dateController.text = DateFormatter.toDisplay(picked));
      _validateForm();
    }
  }

  Future<void> _saveExpense() async {
    if (!_validateForm()) return;
    setState(() => _isSaving = true);
    try {
      final parsedDate = DateFormatter.parse(_dateController.text.trim())!;
      final isoDate = DateFormatter.toIso(parsedDate);
      final amount = CurrencyFormatter.parse(_amountController.text.trim())!;
      final now = DateTime.now().toIso8601String();

      if (_isEditMode) {
        final updatedExpense = widget.existingExpense!.copyWith(
          merchant: _merchantController.text.trim(),
          transactionDate: isoDate,
          totalAmount: amount,
          category: _selectedCategory!,
          thumbnailPath: _effectiveImagePath,
          updatedAt: now,
        );

        await ref.read(expenseListProvider.notifier).updateExpense(updatedExpense);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật giao dịch thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final expense = Expense(
          merchant: _merchantController.text.trim(),
          transactionDate: isoDate,
          totalAmount: amount,
          category: _selectedCategory!,
          thumbnailPath: _effectiveImagePath,
          createdAt: now,
          updatedAt: now,
        );

        await ref.read(expenseListProvider.notifier).addExpense(expense);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu giao dịch thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu giao dịch: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipt = widget.parsedReceipt;
    final isComplete = _isEditMode || (receipt?.isComplete ?? false);
    final isValid = _validateForm(silent: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Chỉnh sửa giao dịch' : 'Kiểm tra thông tin'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReceiptHeader(
                imagePath: _effectiveImagePath,
                rawText: receipt?.rawText ?? '',
                isComplete: isComplete,
              ),
              const SizedBox(height: 16),
              ReviewForm(
                merchantController: _merchantController,
                dateController: _dateController,
                amountController: _amountController,
                merchantError: _merchantError,
                dateError: _dateError,
                amountError: _amountError,
                onSelectDate: _selectDate,
                onChanged: () => _validateForm(),
              ),
              const SizedBox(height: 16),
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() => _selectedCategory = cat);
                  _validateForm();
                },
                errorText: _categoryError,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: (_isSaving || !isValid) ? null : _saveExpense,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isEditMode ? Icons.save : Icons.check_circle_outline),
                label: Text(
                  _isSaving
                      ? (_isEditMode ? 'Đang cập nhật...' : 'Đang lưu...')
                      : (_isEditMode ? 'Cập nhật giao dịch' : 'Lưu giao dịch'),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
