// Trip type enum
import 'package:cloud_firestore/cloud_firestore.dart';

enum TripType { toWork, returnTrip }

extension TripTypeExt on TripType {
  String get displayName {
    return this == TripType.toWork ? 'To Work' : 'Return Trip';
  }

  String get displayNameAr {
    return this == TripType.toWork ? 'ذهاب للعمل' : 'عودة';
  }
}

// Trip model for tracking customer trips
class TripModel {
  final String id;
  final String customerId;
  final String driverId;
  final TripType type;
  final double price;
  final DateTime dateTime;
  final String? notes;
  final int weekNumber;
  final int monthNumber;
  final int year;
  final DateTime? reminderTime;  // NEW: Reminder time for the trip

  TripModel({
    required this.id,
    required this.customerId,
    required this.driverId,
    required this.type,
    required this.price,
    required this.dateTime,
    this.notes,
    required this.weekNumber,
    required this.monthNumber,
    required this.year,
    this.reminderTime,  // NEW
  });

  // Convert TripModel to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'driverId': driverId,
      'type': type == TripType.toWork ? 'toWork' : 'returnTrip',
      'price': price,
      'dateTime': dateTime,  // Let Firestore handle the conversion
      'notes': notes,
      'weekNumber': weekNumber,
      'monthNumber': monthNumber,
      'year': year,
      'reminderTime': reminderTime,  // NEW
    };
  }

  // Create TripModel from JSON
  factory TripModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) {
        return value.toDate();  // Convert Firestore Timestamp to DateTime
      }
      if (value is String) {
        return DateTime.parse(value);  // Parse ISO8601 string
      }
      return DateTime.now();
    }

    return TripModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      driverId: map['driverId'] ?? '',
      type: map['type'] == 'toWork' ? TripType.toWork : TripType.returnTrip,
      price: (map['price'] ?? 0.0).toDouble(),
      dateTime: parseDateTime(map['dateTime']),
      notes: map['notes'],
      weekNumber: map['weekNumber'] ?? 0,
      monthNumber: map['monthNumber'] ?? 0,
      year: map['year'] ?? 0,
      reminderTime: map['reminderTime'] != null ? parseDateTime(map['reminderTime']) : null,  // NEW
    );
  }

  // Copy with method
  TripModel copyWith({
    String? id,
    String? customerId,
    String? driverId,
    TripType? type,
    double? price,
    DateTime? dateTime,
    String? notes,
    int? weekNumber,
    int? monthNumber,
    int? year,
    DateTime? reminderTime,  // NEW
  }) {
    return TripModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      driverId: driverId ?? this.driverId,
      type: type ?? this.type,
      price: price ?? this.price,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      weekNumber: weekNumber ?? this.weekNumber,
      monthNumber: monthNumber ?? this.monthNumber,
      year: year ?? this.year,
      reminderTime: reminderTime ?? this.reminderTime,  // NEW
    );
  }
}
