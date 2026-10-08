import 'dart:io';

import 'package:flutter/material.dart';

// Widget hiển thị ảnh thu nhỏ biên lai, thông báo thiếu thông tin và văn bản thô OCR.
class ReceiptHeader extends StatelessWidget {
  final String? imagePath;
  final String rawText;
  final bool isComplete;

  const ReceiptHeader({
    super.key,
    this.imagePath,
    required this.rawText,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasImage)
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black12,
                image: DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (!isComplete) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade400),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Một số thông tin chưa nhận dạng đầy đủ. Vui lòng bổ sung bên dưới.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (rawText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: ExpansionTile(
              title: Text(
                'Văn bản thô OCR (${rawText.split('\n').length} dòng)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: const Icon(Icons.description_outlined),
              childrenPadding: const EdgeInsets.all(12),
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      rawText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
