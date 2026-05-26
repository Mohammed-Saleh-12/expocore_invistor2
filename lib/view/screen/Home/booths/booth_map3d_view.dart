import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../core/constant/routes.dart';
import '../../../../data/sourcedata/static/exhibitions_dummy.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/custom_button.dart';

class BoothMap3dView extends StatefulWidget {
  const BoothMap3dView({super.key});
  @override
  State<BoothMap3dView> createState() => _BoothMap3dViewState();
}

class _BoothMap3dViewState extends State<BoothMap3dView> {
  int? _selected;
  final _booths = List.generate(20, (i) => {'id': i + 1, 'number': 'B${(i + 1).toString().padLeft(2, '0')}', 'status': i % 5 == 0 ? 'available' : i % 3 == 0 ? 'selected' : 'booked'});

  Color _boothColor(String s, bool sel) {
    if (sel) return AppColors.darkPrimary;
    switch (s) {
      case 'available': return AppColors.info;
      case 'booked':    return AppColors.grey.withOpacity(0.4);
      default:          return AppColors.darkPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const CustomAppBar(title: 'خريطة المعرض 3D'),
      body: Column(children: [
        _legend(context),
        Expanded(
          child: Container(
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            child: Column(children: [
              const Padding(padding: EdgeInsets.all(12), child: Text('اضغط على الجناح للاختيار', style: TextStyle(color: AppColors.grey, fontSize: 13))),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: _booths.length,
                  itemBuilder: (_, i) {
                    final b = _booths[i];
                    final isSelected = _selected == b['id'];
                    final status = b['status'] as String;
                    return GestureDetector(
                      onTap: status == 'available' ? () => setState(() => _selected = isSelected ? null : b['id'] as int) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _boothColor(status, isSelected),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected ? [BoxShadow(color: AppColors.darkPrimary.withOpacity(0.5), blurRadius: 10)] : [],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(b['number'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          if (status == 'available') const Text('متاح', style: TextStyle(color: Colors.white70, fontSize: 9)),
                          if (status == 'booked') const Text('محجوز', style: TextStyle(color: Colors.white70, fontSize: 9)),
                          if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 16),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
        if (_selected != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: Column(children: [
              Row(children: [
                Text('الجناح المختار: B${_selected!.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('السعر: 15,000 ريال', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              CustomButton(
                label: 'احجز هذا الجناح',
                onTap: () => Get.toNamed(AppRoutes.BOOKING_REQUEST, arguments: DummyData.myBooths.first),
              ),
            ]),
          ),
      ]),
    );
  }

  Widget _legend(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _legendItem(AppColors.info, 'متاح'),
      _legendItem(AppColors.grey.withOpacity(0.5), 'محجوز'),
      _legendItem(AppColors.darkPrimary, 'مختار'),
    ]),
  );

  Widget _legendItem(Color c, String l) => Row(children: [
    Container(width: 14, height: 14, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
  ]);
}
