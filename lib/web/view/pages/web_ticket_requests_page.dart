import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/events_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../../../data/model/event/event_model.dart';
import '../../../data/model/event/ticket_request_model.dart';
import '../../controllers/web_nav_controller.dart';

class WebTicketRequestsPage extends StatelessWidget {
  final EventModel event;
  const WebTicketRequestsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: WebNavController.to.closeDetail,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: WebTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WebTheme.border),
                    ),
                    child: Icon(Icons.arrow_forward_rounded, color: WebTheme.text, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('btn_back'.tr, style: TextStyle(color: AppColors.grey, fontSize: 14)),
                ]),
              ),
              const SizedBox(height: 20),
              Text('${'ticket_requests_title'.tr}: ${event.name}',
                  style: TextStyle(color: WebTheme.text, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Obx(() {
                final all = c.getTicketRequests(event.id);
                if (all.isEmpty) {
                  return Container(
                    width: double.infinity, padding: const EdgeInsets.all(50), alignment: Alignment.center,
                    decoration: BoxDecoration(color: WebTheme.surface, borderRadius: BorderRadius.circular(16)),
                    child: Text('no_requests'.tr, style: TextStyle(color: AppColors.grey)),
                  );
                }
                return Column(children: all.map((r) => _RequestCard(req: r, c: c)).toList());
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TicketRequestModel req;
  final EventsController c;
  const _RequestCard({required this.req, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WebTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: WebTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(Icons.person_outline, color: WebTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.requesterName, style: TextStyle(color: WebTheme.text, fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(req.requestedAt, style: TextStyle(color: AppColors.grey, fontSize: 11)),
                  ],
                ),
              ),
              _statusChip(req.status),
            ],
          ),
          const SizedBox(height: 12),
          _row(Icons.phone_outlined, req.requesterPhone),
          const SizedBox(height: 4),
          _row(Icons.email_outlined, req.requesterEmail),

          // QR (approved)
          if (req.status == 'approved' && req.ticketNumber != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, color: AppColors.success, size: 40),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ticket_qr'.tr, style: TextStyle(color: WebTheme.text, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(req.ticketNumber ?? '',
                          style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Actions (pending)
          if (req.status == 'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => c.approveTicketRequest(req),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.check, color: WebTheme.text, size: 16),
                        SizedBox(width: 6),
                        Text('btn_accept_qr'.tr, style: TextStyle(color: WebTheme.text, fontWeight: FontWeight.w700, fontSize: 13)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => c.rejectTicketRequest(req),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.error.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('btn_reject'.tr, style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(children: [
        Icon(icon, size: 15, color: AppColors.grey),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: AppColors.grey, fontSize: 13)),
      ]);

  Widget _statusChip(String s) {
    final map = {
      'approved': ('status_approved'.tr, AppColors.success),
      'rejected': ('مرفوض'.tr, AppColors.error),
      'pending':  ('قيد المراجعة'.tr, AppColors.orange),
    };
    final (label, color) = map[s] ?? ('—', AppColors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
