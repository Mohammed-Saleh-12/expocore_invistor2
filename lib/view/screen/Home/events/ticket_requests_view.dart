import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/Home/events_controller.dart';
import '../../../../core/constant/appcolors.dart';
import '../../../../data/model/event/event_model.dart';
import '../../../../data/model/event/ticket_request_model.dart';
import '../../../widget/Home/custom_app_bar.dart';
import '../../../widget/Home/empty_widget.dart';

class TicketRequestsView extends StatelessWidget {
  const TicketRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final event = Get.arguments as EventModel;
    final ctrl = Get.find<EventsController>();
    final isPaid = event.ticketCategory == 'paid';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          title: ' ${event.name}',
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Obx(() {
                final pending = ctrl.pendingRequestsCount(event.id);
                return pending > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pending معلّق',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }),
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'tab_pending'.tr),
                Tab(text: 'tab_approved'.tr),
                Tab(text: 'tab_rejected'.tr),
              ],
              labelColor: AppColors.darkPrimary,
              indicatorColor: AppColors.darkPrimary,
              unselectedLabelColor: AppColors.grey,
            ),
            Expanded(
              child: Obx(() {
                final all = ctrl.getTicketRequests(event.id);
                final pending = all
                    .where((r) => r.status == 'pending')
                    .toList();
                final approved = all
                    .where((r) => r.status == 'approved')
                    .toList();
                final rejected = all
                    .where((r) => r.status == 'rejected')
                    .toList();
                return TabBarView(
                  children: [
                    // Accept/Reject controls + status chip only for paid events
                    _listTab(context, pending, ctrl,
                        showActions: isPaid, showStatus: isPaid),
                    _listTab(context, approved, ctrl,
                        showQr: true, showStatus: isPaid),
                    _listTab(context, rejected, ctrl, showStatus: isPaid),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTab(
    BuildContext context,
    List<TicketRequestModel> requests,
    EventsController ctrl, {
    bool showActions = false,
    bool showQr = false,
    bool showStatus = true,
  }) {
    if (requests.isEmpty) {
      return EmptyWidget(message: 'no_requests'.tr);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: requests.length,
      itemBuilder: (_, i) => _RequestCard(
        request: requests[i],
        ctrl: ctrl,
        showActions: showActions,
        showQr: showQr,
        showStatus: showStatus,
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TicketRequestModel request;
  final EventsController ctrl;
  final bool showActions;
  final bool showQr;
  final bool showStatus;

  const _RequestCard({
    required this.request,
    required this.ctrl,
    this.showActions = false,
    this.showQr = false,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.darkPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      request.requestedAt,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // chip الحالة مخفي للتذاكر المجانية (لا توجد إدارة قبول/رفض)
              if (showStatus) _statusChip(request.status),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.phone_outlined, request.requesterPhone),
          const SizedBox(height: 4),
          _infoRow(Icons.email_outlined, request.requesterEmail),

          // QR code section (approved tickets)
          if (showQr && request.qrCodeData != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _QrCodeWidget(
                  ticketNumber: request.ticketNumber ?? '',
                  qrData: request.qrCodeData!,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ticket_qr'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          request.ticketNumber ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ticket_sent_note'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Action buttons (pending)
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ctrl.rejectTicketRequest(request),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 16,
                    ),
                    label: Text(
                      'btn_reject'.tr,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => ctrl.approveTicketRequest(request),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      'btn_accept_qr'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = AppColors.success;
        label = 'status_approved'.tr;
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'tab_rejected'.tr;
        break;
      default:
        color = AppColors.orange;
        label = 'tab_pending'.tr;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 13, color: AppColors.grey),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
    ],
  );
}

// Simulated QR code widget (visual placeholder)
class _QrCodeWidget extends StatelessWidget {
  final String ticketNumber;
  final String qrData;

  const _QrCodeWidget({required this.ticketNumber, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: CustomPaint(
        painter: _QrPatternPainter(),
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.qr_code_2, color: Colors.black87, size: 24),
          ),
        ),
      ),
    );
  }
}

class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;
    final cellSize = size.width / 9;

    // QR-like corner squares pattern
    final cornerPositions = [
      const Offset(0, 0),
      const Offset(6, 0),
      const Offset(0, 6),
    ];
    for (final pos in cornerPositions) {
      // Outer square
      canvas.drawRect(
        Rect.fromLTWH(
          pos.dx * cellSize,
          pos.dy * cellSize,
          3 * cellSize,
          3 * cellSize,
        ),
        paint,
      );
      // Inner white
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(
          (pos.dx + 0.5) * cellSize,
          (pos.dy + 0.5) * cellSize,
          2 * cellSize,
          2 * cellSize,
        ),
        whitePaint,
      );
      // Inner black dot
      canvas.drawRect(
        Rect.fromLTWH(
          (pos.dx + 1) * cellSize,
          (pos.dy + 1) * cellSize,
          cellSize,
          cellSize,
        ),
        paint,
      );
    }

    // Random data cells simulation
    final dataCells = [
      const Offset(4, 0),
      const Offset(5, 1),
      const Offset(3, 2),
      const Offset(6, 2),
      const Offset(7, 2),
      const Offset(4, 3),
      const Offset(0, 4),
      const Offset(2, 4),
      const Offset(5, 4),
      const Offset(8, 4),
      const Offset(1, 5),
      const Offset(3, 5),
      const Offset(7, 6),
      const Offset(4, 7),
      const Offset(6, 7),
      const Offset(1, 8),
      const Offset(3, 8),
      const Offset(5, 8),
    ];
    for (final cell in dataCells) {
      canvas.drawRect(
        Rect.fromLTWH(
          cell.dx * cellSize,
          cell.dy * cellSize,
          cellSize,
          cellSize,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
