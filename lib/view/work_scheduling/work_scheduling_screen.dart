// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ut_worx/constant/toaster.dart';
import 'package:ut_worx/firebase_models/fb_work_scheduling_model.dart';
import 'package:ut_worx/utils/custom_widgets/custom_drawer.dart';
import 'package:ut_worx/utils/custom_widgets/custom_widgets.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';
import 'package:ut_worx/view/work_scheduling/create_work_scheduling.dart';

class WorkSchedulingScreen extends StatefulWidget {
  const WorkSchedulingScreen({super.key});

  @override
  State<WorkSchedulingScreen> createState() => _WorkSchedulingScreenState();
}

class _WorkSchedulingScreenState extends State<WorkSchedulingScreen> {
  bool hasFollowUpRequests = false;
  // Add scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  // Add StreamSubscription to manage the listener
  StreamSubscription<QuerySnapshot>? _followUpSubscription;

  @override
  void initState() {
    super.initState();
    // Set up listener for follow-up requests
    _checkForFollowUpRequests();
  }

  // Dispose controllers when widget is disposed
  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    // Cancel the stream subscription to prevent memory leaks
    _followUpSubscription?.cancel();
    super.dispose();
  }

  void _checkForFollowUpRequests() {
    // Listen for preliminary reports with followUps=true
    _followUpSubscription = FirebaseFirestore.instance
        .collection('PreliminaryReports')
        .where('followUps', isEqualTo: true)
        .snapshots()
        .listen((snapshot) async {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        // If there are no follow-up requests at all

        if (mounted) {
          setState(() {
            hasFollowUpRequests = false;
          });
        }
        return;
      }

      try {
        // Get all work scheduling documents to check which follow-ups already have schedules
        final workSchedulingSnapshot =
            await FirebaseFirestore.instance.collection('WorkScheduling').get();

        // Check if widget is still mounted after async operation
        if (!mounted) return;

        final scheduledOrderIds = workSchedulingSnapshot.docs
            .map((doc) => doc.data()['workOrderId'] as String)
            .toSet();

        // Filter out follow-up requests that already have work schedules
        final pendingFollowUps = snapshot.docs.where((doc) {
          final data = doc.data();
          final orderId = data['orderId'] as String?;
          return orderId != null && !scheduledOrderIds.contains(orderId);
        }).toList();

        // Update state based on whether there are any pending follow-ups
        if (mounted) {
          setState(() {
            hasFollowUpRequests = pendingFollowUps.isNotEmpty;
          });
        }
      } catch (e) {
        // Handle any errors gracefully
        debugPrint('Error checking follow-up requests: $e');
        if (mounted) {
          setState(() {
            hasFollowUpRequests = false;
          });
        }
      }
    }, onError: (error) {
      // Handle stream errors
      debugPrint('Stream error in _checkForFollowUpRequests: $error');
      if (mounted) {
        setState(() {
          hasFollowUpRequests = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF4F7FE),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResponsiveLayout(
              builder: (context, responsive) {
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
                final buttonPadding = responsive.deviceValue(
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                );
                final titlePadding = responsive.deviceValue(
                  mobile: 20.0,
                  tablet: 20.0,
                  desktop: 20.0,
                );
                final bool usefullLayout =
                    responsive.isTablet || responsive.isDesktop;

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: titlePadding, right: titlePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Scheduled Task',
                            style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              // Request icon with notification badge
                              Stack(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.notifications_active_outlined,
                                      color: Color(0XFF7DBD2C),
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      _showFollowUpRequestsDialog(context);
                                    },
                                  ),
                                  if (hasFollowUpRequests)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 12,
                                          minHeight: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const CreateWorkScheduling();
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
                                    'Add Schedule Task',
                                    style: TextStyle(fontSize: buttonFontSize),
                                  ),
                                ),
                              ),
                            ],
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
                            .collection('WorkScheduling')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('No work schedules found'),
                            );
                          }

                          // Convert Firestore documents to WorkSchedulingModel objects
                          final List<WorkSchedulingModel> scheduleData =
                              snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return WorkSchedulingModel.fromJson(data);
                          }).toList();

                          // Replace the existing Scrollbar with nested Scrollbars
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
                                      columnSpacing: 20,
                                      horizontalMargin: 15,
                                      headingTextStyle: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: tableTitle),
                                      headingRowColor: WidgetStateProperty.all(
                                          Color(0XFFE5E7EB)),
                                      dataTextStyle:
                                          TextStyle(fontSize: tableTitle),
                                      headingRowHeight: tableRowHeight,
                                      dataRowHeight: tableRowHeight,
                                      columns: const [
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'WORK ORDER ID',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'ASSIGNED PIC',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'SCHEDULED DATE',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'SCHEDULED TIME',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'ESTIMATED HOURS',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'STATUS',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'SPARE PARTS',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: scheduleData.map((data) {
                                        return DataRow(cells: [
                                          DataCell(Text(data.workOrderId)),
                                          DataCell(
                                              Text(data.technicianAssigned)),
                                          DataCell(Text(
                                            data.scheduledDate != null
                                                ? _formatDate(
                                                    data.scheduledDate!)
                                                : 'Not scheduled',
                                          )),
                                          DataCell(Text(data.scheduledTime)),
                                          DataCell(Text(data.estimatedHours)),
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color:
                                                    getStatusColor(data.status),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                data.status,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              width: 120,
                                              child: data.spareParts != null &&
                                                      data.spareParts!
                                                          .isNotEmpty
                                                  ? Wrap(
                                                      spacing: 4,
                                                      runSpacing: 4,
                                                      children: (data.spareParts
                                                              as List<dynamic>)
                                                          .take(2)
                                                          .map((part) {
                                                        return Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                    0XFF7DBD2C)
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0XFF7DBD2C)),
                                                          ),
                                                          child: Text(
                                                            part
                                                                .toString()
                                                                .replaceAll(
                                                                    '_', ' '),
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Color(
                                                                  0XFF7DBD2C),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList()
                                                        ..addAll([
                                                          if ((data.spareParts
                                                                      as List<
                                                                          dynamic>)
                                                                  .length >
                                                              2)
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              child: Text(
                                                                '+${(data.spareParts as List<dynamic>).length - 2}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                ),
                                                              ),
                                                            ),
                                                        ]),
                                                    )
                                                  : Text(
                                                      'No spare parts',
                                                      style: TextStyle(
                                                        color: Colors.grey,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFollowUpRequestsDialog(BuildContext context) async {
    if (!mounted) return;

    try {
      final followUpRequestsSnapshot = await FirebaseFirestore.instance
          .collection('PreliminaryReports')
          .where('followUps', isEqualTo: true)
          .get();

      if (!mounted) return;

      // Get all work scheduling documents to check which follow-ups already have schedules
      final workSchedulingSnapshot =
          await FirebaseFirestore.instance.collection('WorkScheduling').get();

      if (!mounted) return;

      final scheduledOrderIds = workSchedulingSnapshot.docs
          .map((doc) => doc.data()['workOrderId'] as String)
          .toSet();

      // Filter out follow-up requests that already have work schedules
      final pendingFollowUps = followUpRequestsSnapshot.docs.where((doc) {
        final data = doc.data();
        final orderId = data['orderId'] as String?;
        return orderId != null && !scheduledOrderIds.contains(orderId);
      }).toList();

      // Update state based on whether there are any pending follow-ups
      if (mounted) {
        setState(() {
          hasFollowUpRequests = pendingFollowUps.isNotEmpty;
        });
      }

      if (pendingFollowUps.isEmpty) {
        // If there are no pending follow-up requests, show a message
        Toaster.showToast('No pending follow-up requests');
        return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 500,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow-Up Requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('PreliminaryReports')
                        .where('followUps', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No follow-up requests found');
                      }

                      return Container(
                        height: 300,
                        child: SingleChildScrollView(
                          child: Column(
                            children: snapshot.data!.docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return Card(
                                margin: EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(data['orderTitle'] ?? 'No Title'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Order ID: ${data['orderId'] ?? 'N/A'}'),
                                      Text(
                                          'Asset: ${data['assetSelection'] ?? 'N/A'}'),
                                      Text(
                                          'Findings: ${data['findings'] ?? 'N/A'}'),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showCreateWorkScheduleDialog(
                                          context, data);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0XFF7DBD2C),
                                    ),
                                    child: Text(
                                      'Schedule Work',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing follow-up requests dialog: $e');
      if (mounted) {
        Toaster.showToast('Error loading follow-up requests');
      }
    }
  }

  void _showCreateWorkScheduleDialog(
      BuildContext context, Map<String, dynamic> followUpData) {
    final TextEditingController workOrderIdController = TextEditingController(
      text: followUpData['orderId'] ?? '',
    );
    final TextEditingController workOrderTitleController =
        TextEditingController(
      text: followUpData['orderTitle'] ?? '',
    );
    final TextEditingController assetSelectionController =
        TextEditingController(
      text: followUpData['assetSelection'] ?? '',
    );
    final TextEditingController workDescriptionController =
        TextEditingController();
    final TextEditingController assignedToController = TextEditingController();
    final TextEditingController estimatedHoursController =
        TextEditingController();

    String priority = 'Medium';
    DateTime scheduledDate = DateTime.now();
    TimeOfDay scheduledTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 600,
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Work Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Work Order ID
                      Text('Work Order ID:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextField(
                        controller: workOrderIdController,
                        enabled: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Colors.grey[200],
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 15),

                      // Work Order Title
                      Text('Work Order Title:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextField(
                        controller: workOrderTitleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter work order title',
                        ),
                      ),
                      SizedBox(height: 15),

                      // Asset Selection
                      Text('Asset Selection:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextField(
                        controller: assetSelectionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter asset selection',
                        ),
                      ),
                      SizedBox(height: 15),

                      // Work Description
                      Text('Work Description:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextField(
                        controller: workDescriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter work description',
                        ),
                      ),
                      SizedBox(height: 15),

                      // Assigned To
                      Text('Assigned To:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextField(
                        controller: assignedToController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter assigned person',
                        ),
                      ),
                      SizedBox(height: 15),

                      // Priority
                      Text('Priority:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: ['Low', 'Medium', 'High', 'Critical']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            priority = newValue ?? 'Medium';
                          });
                        },
                      ),
                      SizedBox(height: 15),

                      // Scheduled Date
                      Text('Scheduled Date:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: scheduledDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != scheduledDate) {
                            setState(() {
                              scheduledDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}'),
                              Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Scheduled Time
                      Text('Scheduled Time:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: scheduledTime,
                          );
                          if (picked != null && picked != scheduledTime) {
                            setState(() {
                              scheduledTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${scheduledTime.format(context)}'),
                              Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Estimated Hours
                      Text('Estimated Hours:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextField(
                        controller: estimatedHoursController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter estimated hours',
                        ),
                      ),
                      SizedBox(height: 25),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await _createWorkSchedule(
                                context,
                                workOrderIdController.text,
                                workOrderTitleController.text,
                                assetSelectionController.text,
                                workDescriptionController.text,
                                assignedToController.text,
                                priority,
                                scheduledDate,
                                scheduledTime,
                                estimatedHoursController.text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0XFF7DBD2C),
                            ),
                            child: Text(
                              'Create Schedule',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createWorkSchedule(
    BuildContext context,
    String workOrderId,
    String workOrderTitle,
    String assetSelection,
    String workDescription,
    String assignedTo,
    String priority,
    DateTime scheduledDate,
    TimeOfDay scheduledTime,
    String estimatedHours,
  ) async {
    if (!mounted) return;

    try {
      // Validation
      if (workOrderTitle.isEmpty) {
        Toaster.showToast('Work order title cannot be empty');
        return;
      }
      if (workDescription.isEmpty) {
        Toaster.showToast('Work description cannot be empty');
        return;
      }
      if (assignedTo.isEmpty) {
        Toaster.showToast('Assigned to cannot be empty');
        return;
      }
      if (estimatedHours.isEmpty) {
        Toaster.showToast('Estimated hours cannot be empty');
        return;
      }

      EasyLoading.show(status: 'Creating work schedule...');

      // Combine date and time
      final scheduledDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      // Create work schedule data
      final workScheduleData = {
        'workOrderId': workOrderId,
        'workOrderTitle': workOrderTitle,
        'assetSelection': assetSelection,
        'workDescription': workDescription,
        'assignedTo': assignedTo,
        'priority': priority,
        'scheduledDateTime': Timestamp.fromDate(scheduledDateTime),
        'estimatedHours': double.tryParse(estimatedHours) ?? 0.0,
        'status': 'Scheduled',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.email ?? '',
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('WorkScheduling')
          .add(workScheduleData);

      EasyLoading.dismiss();

      if (mounted) {
        Navigator.of(context).pop();
        Toaster.showToast('Work schedule created successfully');
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        Toaster.showToast('Error creating work schedule: $e');
      }
      debugPrint('Error creating work schedule: $e');
    }
  }
}
