class DeliverySlotModel {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String label;
  final bool isAvailable;
  final int capacity;
  final int bookedCount;

  DeliverySlotModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.label,
    this.isAvailable = true,
    this.capacity = 10,
    this.bookedCount = 0,
  });

  String get formattedSlot => '$label ($startTime - $endTime)';

  factory DeliverySlotModel.fromJson(Map<String, dynamic> json) {
    return DeliverySlotModel(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? json['start_time']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? json['end_time']?.toString() ?? '11:00',
      label: json['label']?.toString() ?? json['formattedWindow']?.toString() ?? '${json['startTime']} - ${json['endTime']}',
      isAvailable: json['isAvailable'] ?? json['available'] ?? true,
      capacity: json['capacity'] ?? 10,
      bookedCount: json['bookedCount'] ?? json['booked_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'label': label,
      'isAvailable': isAvailable,
      'capacity': capacity,
      'bookedCount': bookedCount,
    };
  }
}
