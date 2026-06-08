import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkPrimary),
      ),
    );
  }
}
