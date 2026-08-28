import 'package:flutter_test/flutter_test.dart';
import 'package:userapp/models/delivery_slot_model.dart';

void main() {
  group('DeliverySlotModel tests', () {
    test('parses and formats 2-hour delivery slot correctly', () {
      final slot = DeliverySlotModel.fromJson({
        'id': 'slt_0911',
        'date': '2026-08-29',
        'startTime': '09:00',
        'endTime': '11:00',
        'label': '09:00 AM - 11:00 AM',
        'isAvailable': true,
        'capacity': 10,
        'bookedCount': 2,
      });

      expect(slot.id, 'slt_0911');
      expect(slot.startTime, '09:00');
      expect(slot.endTime, '11:00');
      expect(slot.formattedSlot, '09:00 AM - 11:00 AM (09:00 - 11:00)');
      expect(slot.isAvailable, isTrue);
    });
  });
}
