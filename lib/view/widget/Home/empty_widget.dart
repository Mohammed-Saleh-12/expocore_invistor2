import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const EmptyWidget({
    super.key,
    required this.message,
    this.buttonLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.grey, fontSize: 16), textAlign: TextAlign.center),
          if (buttonLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
