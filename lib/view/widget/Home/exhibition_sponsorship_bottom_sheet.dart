import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Home/exhibition_detail_controller.dart';
import '../../../core/constant/appcolors.dart';

class ExhibitionSponsorshipBottomSheet extends StatelessWidget {
  final ExhibitionDetailController controller;
  const ExhibitionSponsorshipBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      _field(controller.companyNameCtrl, 'اسم الشركة', Icons.business_outlined),
      _field(
        controller.companyTypeCtrl,
        'نوع الشركة / النشاط',
        Icons.category_outlined,
      ),
      _field(
        controller.websiteCtrl,
        'الموقع الإلكتروني (اختياري)',
        Icons.language_outlined,
      ),
      _field(controller.contactNameCtrl, 'اسم المسؤول', Icons.person_outline),
      _field(
        controller.contactPhoneCtrl,
        'رقم الهاتف',
        Icons.phone_outlined,
        required: true,
      ),
      _field(
        controller.contactEmailCtrl,
        'البريد الإلكتروني',
        Icons.email_outlined,
        required: true,
      ),
      DropdownButtonFormField<String>(
        value: controller.proposedTier.value.isEmpty
            ? null
            : controller.proposedTier.value,
        decoration: _decoration(
          'الباقة المقترحة',
          Icons.workspace_premium_outlined,
        ),
        items: const [
          DropdownMenuItem(value: 'title', child: Text('Title')),
          DropdownMenuItem(value: 'gold', child: Text('Gold')),
          DropdownMenuItem(value: 'silver', child: Text('Silver')),
          DropdownMenuItem(value: 'bronze', child: Text('Bronze')),
        ],
        onChanged: (value) => controller.proposedTier.value = value ?? '',
      ),
      _field(
        controller.proposedAmountCtrl,
        'المبلغ المقترح',
        Icons.payments_outlined,
        keyboard: TextInputType.number,
      ),
      _field(
        controller.offerDetailsCtrl,
        'تفاصيل العرض',
        Icons.description_outlined,
        maxLines: 3,
      ),
      _field(
        controller.conditionsCtrl,
        'الشروط',
        Icons.rule_outlined,
        maxLines: 3,
      ),
      _field(
        controller.contractTermsCtrl,
        'بنود العقد',
        Icons.article_outlined,
        maxLines: 3,
      ),
      _field(
        controller.startDateCtrl,
        'تاريخ البداية YYYY-MM-DD',
        Icons.calendar_today_outlined,
      ),
      _field(
        controller.endDateCtrl,
        'تاريخ النهاية YYYY-MM-DD',
        Icons.event_outlined,
      ),
    ];

    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'طلب رعاية المعرض',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'أدخل البيانات المطلوبة لإرسال الطلب إلى إدارة المعرض',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 18),
              ...fields.expand((field) => [field, const SizedBox(height: 12)]),
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isSponsorshipSubmitting.value
                      ? null
                      : () async {
                          final sent = await controller
                              .submitSponsorshipRequest();
                          if (sent && context.mounted)
                            Navigator.of(context).pop();
                        },
                  icon: controller.isSponsorshipSubmitting.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    controller.isSponsorshipSubmitting.value
                        ? 'جار الإرسال...'
                        : 'إرسال طلب الرعاية',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController textController,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(required ? '$label *' : label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.grey),
    prefixIcon: Icon(icon, color: AppColors.grey),
    filled: true,
    fillColor: AppColors.darkCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
