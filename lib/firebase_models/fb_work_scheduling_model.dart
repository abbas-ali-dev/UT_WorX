import 'package:cloud_firestore/cloud_firestore.dart';

class WorkSchedulingModel {
  final String workOrderId;
  final String technicianAssigned;
  final DateTime? scheduledDate;
  final String scheduledTime;
  final String estimatedHours;
  final String status;
  final List<dynamic>? spareParts;
  final String createdBy;
  final DateTime? createdAt;

  WorkSchedulingModel({
    required this.workOrderId,
    required this.technicianAssigned,
    this.scheduledDate,
    required this.scheduledTime,
    required this.estimatedHours,
    required this.status,
    this.spareParts,
    required this.createdBy,
    this.createdAt,
  });

  // Firebase سے ڈیٹا حاصل کرنے کے لیے
  factory WorkSchedulingModel.fromJson(Map<String, dynamic> json) {
    DateTime? scheduledDate;
    if (json['scheduledDate'] != null) {
      scheduledDate = (json['scheduledDate'] as Timestamp).toDate();
    }

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    }

    return WorkSchedulingModel(
      workOrderId: json['workOrderId'] ?? '',
      technicianAssigned: json['technicianAssigned'] ?? '',
      scheduledDate: scheduledDate,
      scheduledTime: json['scheduledTime'] ?? '',
      estimatedHours: json['estimatedHours'] ?? '',
      status: json['status'] ?? 'Pending',
      spareParts: json['spareParts'] as List<dynamic>?,
      createdBy: json['createdBy'] ?? '',
      createdAt: createdAt,
    );
  }

  // Firebase میں ڈیٹا بھیجنے کے لیے
  Map<String, dynamic> toJson() {
    return {
      'workOrderId': workOrderId,
      'technicianAssigned': technicianAssigned,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'estimatedHours': estimatedHours,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}
