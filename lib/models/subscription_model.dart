// Subscription type enum
import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionType { weekly, monthly }

extension SubscriptionTypeExt on SubscriptionType {
  String get displayName {
    return this == SubscriptionType.weekly ? 'Weekly' : 'Monthly';
  }

  String get displayNameAr {
    return this == SubscriptionType.weekly ? 'أسبوعي' : 'شهري';
  }
}

// Subscription model for customers
class SubscriptionModel {
  final String id;
  final String customerId;
  final SubscriptionType type;
  final double fee;
  final double oneWayPrice;
  final double returnPrice;
  final double currentBalance;
  final int tripsUsed;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isPaid;
  final DateTime? reminderTime;  // NEW: Reminder time for subscription

  SubscriptionModel({
    required this.id,
    required this.customerId,
    required this.type,
    required this.fee,
    required this.oneWayPrice,
    required this.returnPrice,
    required this.currentBalance,
    required this.tripsUsed,
    required this.startDate,
    this.endDate,
    this.isPaid = false,
    this.reminderTime,  // NEW
  });

  // Convert SubscriptionModel to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type == SubscriptionType.weekly ? 'weekly' : 'monthly',
      'fee': fee,
      'oneWayPrice': oneWayPrice,
      'returnPrice': returnPrice,
      'currentBalance': currentBalance,
      'tripsUsed': tripsUsed,
      'startDate': startDate,  // Let Firestore handle the conversion
      'endDate': endDate,
      'isPaid': isPaid,
      'reminderTime': reminderTime,  // NEW
    };
  }

  // Create SubscriptionModel from JSON
  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
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

    return SubscriptionModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      type: map['type'] == 'weekly' || map['type'] == SubscriptionType.weekly ? SubscriptionType.weekly : SubscriptionType.monthly,
      fee: (map['fee'] ?? 0.0).toDouble(),
      oneWayPrice: (map['oneWayPrice'] ?? 0.0).toDouble(),
      returnPrice: (map['returnPrice'] ?? 0.0).toDouble(),
      currentBalance: (map['currentBalance'] ?? 0.0).toDouble(),
      tripsUsed: map['tripsUsed'] ?? 0,
      startDate: parseDateTime(map['startDate']),
      endDate: map['endDate'] != null ? parseDateTime(map['endDate']) : null,
      isPaid: map['isPaid'] ?? false,
      reminderTime: map['reminderTime'] != null ? parseDateTime(map['reminderTime']) : null,  // NEW
    );
  }

  // Copy with method
  SubscriptionModel copyWith({
    String? id,
    String? customerId,
    SubscriptionType? type,
    double? fee,
    double? oneWayPrice,
    double? returnPrice,
    double? currentBalance,
    int? tripsUsed,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPaid,
    DateTime? reminderTime,  // NEW
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      fee: fee ?? this.fee,
      oneWayPrice: oneWayPrice ?? this.oneWayPrice,
      returnPrice: returnPrice ?? this.returnPrice,
      currentBalance: currentBalance ?? this.currentBalance,
      tripsUsed: tripsUsed ?? this.tripsUsed,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isPaid: isPaid ?? this.isPaid,
      reminderTime: reminderTime ?? this.reminderTime,  // NEW
    );
  }
}
