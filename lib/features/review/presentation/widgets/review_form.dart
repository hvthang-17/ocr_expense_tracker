import 'package:flutter/material.dart';

// Form nhập thông tin cửa hàng, ngày giao dịch và số tiền chi tiêu.
class ReviewForm extends StatelessWidget {
  final TextEditingController merchantController;
  final TextEditingController dateController;
  final TextEditingController amountController;
  final String? merchantError;
  final String? dateError;
  final String? amountError;
  final VoidCallback onSelectDate;
  final VoidCallback onChanged;

  const ReviewForm({
    super.key,
    required this.merchantController,
    required this.dateController,
    required this.amountController,
    this.merchantError,
    this.dateError,
    this.amountError,
    required this.onSelectDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên cửa hàng
        TextFormField(
          controller: merchantController,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Tên cửa hàng / Đơn vị *',
            hintText: 'Nhập tên cửa hàng',
            prefixIcon: const Icon(Icons.storefront),
            errorText: merchantError,
            focusedBorder: merchantError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  )
                : null,
            suffixIcon: merchantController.text.isEmpty
                ? Tooltip(
                    message: 'Trường chưa có thông tin',
                    child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // Ngày giao dịch
        TextFormField(
          controller: dateController,
          readOnly: true,
          onTap: onSelectDate,
          decoration: InputDecoration(
            labelText: 'Ngày giao dịch *',
            hintText: 'DD/MM/YYYY',
            prefixIcon: const Icon(Icons.calendar_month),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dateController.text.isEmpty)
                  Tooltip(
                    message: 'Trường chưa có thông tin',
                    child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: onSelectDate,
                  tooltip: 'Chọn ngày',
                ),
              ],
            ),
            errorText: dateError,
          ),
        ),
        const SizedBox(height: 16),

        // Số tiền
        TextFormField(
          controller: amountController,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Tổng tiền (VND) *',
            hintText: 'Ví dụ: 55000',
            prefixIcon: const Icon(Icons.payments),
            suffixText: 'VND',
            suffixIcon: amountController.text.isEmpty
                ? Tooltip(
                    message: 'Trường chưa có thông tin',
                    child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                  )
                : null,
            errorText: amountError,
          ),
        ),
      ],
    );
  }
}
