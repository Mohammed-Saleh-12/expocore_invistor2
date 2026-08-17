import 'package:expocore_invistor2/data/model/notification/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationModel', () {
    test('maps Laravel notification payload from database', () {
      final model = NotificationModel.fromJson({
        'id': 12,
        'user_id': 34,
        'title': 'New offer',
        'message': 'Your campaign is ready',
        'type': 'campaign_ready',
        'is_read': true,
        'created_at': '2026-08-16T12:00:00Z',
        'payload': {'screen': '/campaigns/5'},
      });

      expect(model.id, 12);
      expect(model.userId, 34);
      expect(model.title, 'New offer');
      expect(model.message, 'Your campaign is ready');
      expect(model.type, 'campaign_ready');
      expect(model.isRead, true);
      expect(model.payload['screen'], '/campaigns/5');
      expect(model.createdAt, isNotNull);
    });
  });
}
