import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String orderId;
  final String orderTitle;
  final String assetSelection;
  final String findings;
  final bool followUps;
  final String createdBy;
  final DateTime? createdAt;
  final String status;
  final String? imageData;
  final String? imageName;

  ReportModel({
    required this.orderId,
    required this.orderTitle,
    required this.assetSelection,
    required this.findings,
    required this.followUps,
    required this.createdBy,
    this.createdAt,
    required this.status,
    this.imageData,
    this.imageName,
  });

  // Factory constructor to create a ReportModel from Firestore data
  factory ReportModel.fromFirestore(Map<String, dynamic> data) {
    return ReportModel(
      orderId: data['orderId'] ?? '',
      orderTitle: data['orderTitle'] ?? '',
      assetSelection: data['assetSelection'] ?? '',
      findings: data['findings'] ?? '',
      followUps: data['followUps'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'Pending',
      imageData: data['imageData'],
      imageName: data['imageName'],
    );
  }

  // Convert model to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderTitle': orderTitle,
      'assetSelection': assetSelection,
      'findings': findings,
      'followUps': followUps,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'status': status,
      'imageData': imageData,
      'imageName': imageName,
    };
  }
}
