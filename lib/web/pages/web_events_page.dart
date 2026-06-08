import 'package:flutter/material.dart';
import '../web_theme.dart';
import 'package:get/get.dart';
import '../../controller/Home/events_controller.dart';
import '../../core/constant/appcolors.dart';
import '../../data/model/event/event_model.dart';
import '../widgets/web_section_header.dart';
import '../widgets/web_status_chip.dart';
import '../controllers/web_nav_controller.dart';

// ════════════════════════════════════════════════════════════
//  WebEventsPage  —  الفعاليات (تبويبات: فعالياتي / الرعايات)
// ════════════════════════════════════════════════════════════
class WebEventsPage extends StatelessWidget {
  const WebEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebSectionHeader(
            title: 'فعالياتي',
            subtitle: 'فعالياتك المنشورة في الأجنحة',
            action: _newBtn(),
          ),
          const SizedBox(height: 24),
          Obx(() => _myEvents(c)),
        ],
      ),
    );
  }

  // ── My events grid ────────────────────────────────────────
  Widget _myEvents(EventsController c) {
    final list = c.myEvents.toList();
    if (c.isLoading.value) {
      return Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.darkPrimary)));
    }
    if (list.isEmpty) return _empty(Icons.event_busy_rounded, 'لا توجد فعاليات');
    return Wrap(
      spacing: 20, runSpacing: 20,
      children: list.map((e) => SizedBox(
        width: 340,
        child: _EventCard(event: e, c: c),
      )).toList(),
    );
  }

  Widget _newBtn() => GestureDetector(
        onTap: WebNavController.to.openCreateEvent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(gradient: AppColors.favoriteGradient, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_rounded, color: WebTheme.text, size: 18),
            SizedBox(width: 6),
            Text('نشر فعالية', style: TextStyle(color: WebTheme.text, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _empty(IconData icon, String msg) => Container(
        width: double.infinity, padding: const EdgeInsets.all(60), alignment: Alignment.center,
        child: Column(children: [
          Icon(icon, size: 56, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(msg, style: TextStyle(color: AppColors.grey)),
        ]),
      );
}

// ── Event card ──────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final EventModel event;
  final EventsController c;
  const _EventCard({required this.event, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => WebNavController.to.openEvent(event),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: WebTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: WebTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.darkPrimary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(event.type, style: TextStyle(color: AppColors.darkPink, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                WebStatusChip(status: event.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(event.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: WebTheme.text, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.grey.withOpacity(0.85), fontSize: 12, height: 1.5)),
            const SizedBox(height: 16),
            Row(
              children: [
                _info(Icons.calendar_today_outlined, event.date),
                const SizedBox(width: 14),
                _info(Icons.people_outline, '${event.registeredCount}/${event.maxParticipants}'),
                const Spacer(),
                // طلبات التذاكر
                Obx(() {
                  final pending = c.pendingRequestsCount(event.id);
                  return GestureDetector(
                    onTap: () => WebNavController.to.openTicketRequests(event),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.darkSecondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.confirmation_number_outlined, size: 13, color: AppColors.darkSecondary),
                        const SizedBox(width: 4),
                        Text(pending > 0 ? '$pending طلب' : 'التذاكر',
                            style: TextStyle(color: AppColors.darkSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.grey),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      );
}
