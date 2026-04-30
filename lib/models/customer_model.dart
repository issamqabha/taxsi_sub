// Customer model
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String driverId;
  final String name;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastTripDate;
  final bool isActive;

  CustomerModel({
    required this.id,
    required this.driverId,
    required this.name,
    this.phoneNumber,
    required this.createdAt,
    this.lastTripDate,
    this.isActive = true,
  });

  // Convert CustomerModel to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,  // Let Firestore handle the conversion
      'lastTripDate': lastTripDate,
      'isActive': isActive,
    };
  }

  // Create CustomerModel from JSON
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
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

    return CustomerModel(
      id: map['id'] ?? '',
      driverId: map['driverId'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      createdAt: parseDateTime(map['createdAt']),
      lastTripDate: map['lastTripDate'] != null ? parseDateTime(map['lastTripDate']) : null,
      isActive: map['isActive'] ?? true,
    );
  }

  // Copy with method
  CustomerModel copyWith({
    String? id,
    String? driverId,
    String? name,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastTripDate,
    bool? isActive,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastTripDate: lastTripDate ?? this.lastTripDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
