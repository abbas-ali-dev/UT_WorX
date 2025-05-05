// ignore_for_file: deprecated_member_use// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ut_worx/firebase_models/fb_notification_model.dart';
import 'package:ut_worx/utils/custom_widgets/custom_drawer.dart';
import 'package:ut_worx/utils/custom_widgets/custom_widgets.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';
import 'package:ut_worx/view/notification_creation/create_notification.dart';

class NotificationListScreen extends StatefulWidget {
  final String searchQuery;

  const NotificationListScreen({super.key, this.searchQuery = ''});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(builder: (context, responsives) {
      return Scaffold(
        backgroundColor: const Color(0XFFF4F7FE),
        drawer: const CustomDrawer(),
        body: NotificationTable(searchQuery1: widget.searchQuery),
      );
    });
  }
}

class NotificationTable extends StatefulWidget {
  final String searchQuery1;

  const NotificationTable({super.key, this.searchQuery1 = ''});

  @override
  State<NotificationTable> createState() => _NotificationTableState();
}

class _NotificationTableState extends State<NotificationTable> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(builder: (context, responsive) {
      final titlePadding = responsive.deviceValue(
        mobile: 20.0,
        tablet: 20.0,
        desktop: 20.0,
      );
      final titleFontSize = responsive.deviceValue(
        mobile: 14.0,
        tablet: 18.0,
        desktop: 22.0,
      );
      final buttonFontSize = responsive.deviceValue(
        mobile: 10.0,
        tablet: 12.0,
        desktop: 16.0,
      );
      final buttonPadding = responsive.deviceValue(
        mobile: 8.0,
        tablet: 10.0,
        desktop: 12.0,
      );
      final tableTitle = responsive.deviceValue(
        mobile: 10.0,
        tablet: 13.0,
        desktop: 15.0,
      );
      final tableRowHeight = responsive.deviceValue(
        mobile: 30.0,
        tablet: 40.0,
        desktop: 50.0,
      );
      final bool usefullLayout = responsive.isTablet || responsive.isDesktop;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: titlePadding, right: titlePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notification',
                    style: TextStyle(
                        fontSize: titleFontSize, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const NotificationDialog();
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Color(0XFF7DBD2C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(buttonPadding),
                      child: Text(
                        'Create Notification',
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Notifications')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0XFF7DBD2C),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No notifications found'),
                    );
                  }

                  // Convert Firestore documents to NotificationDataModel objects
                  List<NotificationModel> notificationData =
                      snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    DateTime? createdAt;
                    if (data['createdAt'] != null) {
                      createdAt = (data['createdAt'] as Timestamp).toDate();
                    }

                    return NotificationModel(
                      orderId: data['orderId'] ?? '',
                      orderTitle: data['orderTitle'] ?? '',
                      description: data['description'] ?? '',
                      prelimFinding: data['prelimFinding'] ?? '',
                      assetSelection: data['assetSelection'] ?? '',
                      workCategory: data['workCategory'] ?? '',
                      createdBy: data['createdBy'] ?? '',
                      status: data['status'] ?? 'Pending',
                      priority: data['priority'] ?? '',
                      breakdownBypass: data['breakdownBypass'] ?? '',
                      createdAt: createdAt,
                      imageData: data['imageData'] ?? '',
                      imageName: data['imageName'] ?? '',
                    );
                  }).toList();

                  // Filter the notification data based on search query
                  if (widget.searchQuery1.isNotEmpty) {
                    final query = widget.searchQuery1.toLowerCase();
                    notificationData = notificationData.where((notification) {
                      return notification.orderId
                              .toLowerCase()
                              .contains(query) ||
                          notification.orderTitle
                              .toLowerCase()
                              .contains(query) ||
                          notification.assetSelection
                              .toLowerCase()
                              .contains(query) ||
                          notification.createdBy
                              .toLowerCase()
                              .contains(query) ||
                          notification.status.toLowerCase().contains(query) ||
                          notification.priority.toLowerCase().contains(query) ||
                          notification.description
                              .toLowerCase()
                              .contains(query) ||
                          notification.workCategory
                              .toLowerCase()
                              .contains(query);
                    }).toList();
                  }

                  // If no results after filtering
                  if (notificationData.isEmpty &&
                      widget.searchQuery1.isNotEmpty) {
                    return Center(
                      child: Text(
                        'No results found for "${widget.searchQuery1}"',
                        style: TextStyle(fontSize: tableTitle),
                      ),
                    );
                  }

                  return Scrollbar(
                    thumbVisibility: true,
                    controller: _verticalScrollController,
                    thickness: 8,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        thickness: 8,
                        radius: const Radius.circular(10),
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: usefullLayout
                                ? MediaQuery.sizeOf(context).width * 1.3
                                : 800,
                            margin: EdgeInsets.only(bottom: 15),
                            child: DataTable(
                              columnSpacing: 10,
                              horizontalMargin: 10,
                              headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: tableTitle),
                              headingRowColor:
                                  WidgetStateProperty.all(Color(0XFFE5E7EB)),
                              dataTextStyle: TextStyle(fontSize: tableTitle),
                              headingRowHeight: tableRowHeight,
                              dataRowHeight: tableRowHeight,
                              columns: const [
                                DataColumn(
                                    label: Expanded(
                                  child: Text(
                                    'ORDER ID',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                                DataColumn(
                                    label: Expanded(
                                  child: Text(
                                    'ORDER TITLE',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                                DataColumn(
                                    label: Expanded(
                                  child: Text(
                                    'ASSET SELECTION',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                                // DataColumn(
                                //     label: Expanded(
                                //   child: Text(
                                //     'PRELIM FINDING',
                                //     overflow: TextOverflow.ellipsis,
                                //     maxLines: 1,
                                //   ),
                                // )),
                                DataColumn(
                                    label: Expanded(
                                  child: Text(
                                    'CREATED BY',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                                DataColumn(
                                    label: Expanded(
                                  child: Text(
                                    'STATUS',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                                DataColumn(
                                    label: Expanded(
                                  child: Text(
                                    'PRIORITY',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                                DataColumn(
                                    label: Expanded(
                                  child: Text(
                                    'ACTIONS',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                              ],
                              rows: notificationData.map((data) {
                                return DataRow(cells: [
                                  DataCell(Text(data.orderId)),
                                  DataCell(Text(data.orderTitle)),
                                  DataCell(Text(data.assetSelection)),
                                  // DataCell(Text(data.prelimFinding)),
                                  DataCell(Text(data.createdBy)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(data.status),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        data.status,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      data.priority,
                                      style: TextStyle(
                                          color:
                                              getPriorityColor(data.priority)),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        _showNotificationDetailsDialog(
                                            context, data);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0XFF7DBD2C),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        minimumSize: Size(60, 25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: Text(
                                        'View',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showNotificationDetailsDialog(
      BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ResponsiveLayout(
            builder: (context, responsive) {
              final dialogWidth = responsive.deviceValue(
                mobile: 320.0,
                tablet: 450.0,
                desktop: 550.0,
              );

              final padding = responsive.deviceValue(
                mobile: 16.0,
                tablet: 20.0,
                desktop: 24.0,
              );

              final titleFontSize = responsive.deviceValue(
                mobile: 18.0,
                tablet: 20.0,
                desktop: 22.0,
              );

              final labelFontSize = responsive.deviceValue(
                mobile: 14.0,
                tablet: 15.0,
                desktop: 16.0,
              );

              final contentFontSize = responsive.deviceValue(
                mobile: 13.0,
                tablet: 14.0,
                desktop: 15.0,
              );

              return Container(
                width: dialogWidth,
                padding: EdgeInsets.all(padding),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Notification Details',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Order ID
                      buildDetailRow(
                        'Order ID:',
                        notification.orderId,
                        labelFontSize,
                        contentFontSize,
                      ),
                      SizedBox(height: 10),

                      // Order Title
                      buildDetailRow(
                        'Order Title:',
                        notification.orderTitle,
                        labelFontSize,
                        contentFontSize,
                      ),
                      SizedBox(height: 10),

                      // Description
                      buildDetailRow(
                        'Description:',
                        notification.description,
                        labelFontSize,
                        contentFontSize,
                      ),
                      SizedBox(height: 10),

                      // Asset Selection
                      buildDetailRow(
                        'Asset Selection:',
                        notification.assetSelection,
                        labelFontSize,
                        contentFontSize,
                      ),
                      SizedBox(height: 10),

                      // Work Category
                      buildDetailRow(
                        'Work Category:',
                        notification.workCategory,
                        labelFontSize,
                        contentFontSize,
                      ),
                      SizedBox(height: 10),

                      // Priority
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: labelFontSize,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            notification.priority,
                            style: TextStyle(
                              fontSize: contentFontSize,
                              color: getPriorityColor(notification.priority),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: labelFontSize,
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(notification.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.status,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: contentFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Breakdown/Bypass
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Breakdown/Bypass:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: labelFontSize,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            notification.breakdownBypass ? 'Yes' : 'No',
                            style: TextStyle(
                              fontSize: contentFontSize,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Created By
                      buildDetailRow(
                        'Created By:',
                        notification.createdBy,
                        labelFontSize,
                        contentFontSize,
                      ),
                      SizedBox(height: 10),

                      // Created At
                      buildDetailRow(
                        'Created At:',
                        notification.createdAt != null
                            ? formatDateTime(notification.createdAt!)
                            : '',
                        labelFontSize,
                        contentFontSize,
                      ),

                      SizedBox(height: 20),

                      // Image Section - Add this new section
                      if (notification.imageData != null &&
                          notification.imageData!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attachment:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: labelFontSize,
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: 200,
                                  maxWidth: dialogWidth * 0.8,
                                ),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(notification.imageData!),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            if (notification.imageName != null &&
                                notification.imageName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Center(
                                  child: Text(
                                    notification.imageName!,
                                    style: TextStyle(
                                      fontSize: contentFontSize * 0.9,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                      SizedBox(height: 20),

                      // Close button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0XFF7DBD2C),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: contentFontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
