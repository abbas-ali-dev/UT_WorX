// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // Set up listener for follow-up requests
    _checkForFollowUpRequests();
  }

  void _checkForFollowUpRequests() {
    // Listen for preliminary reports with followUps=true
    FirebaseFirestore.instance
        .collection('PreliminaryReports')
        .where('followUps', isEqualTo: true)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        // If there are no follow-up requests at all
        setState(() {
          hasFollowUpRequests = false;
        });
        return;
      }

      // Get all work scheduling documents to check which follow-ups already have schedules
      final workSchedulingSnapshot =
          await FirebaseFirestore.instance.collection('WorkScheduling').get();

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
      setState(() {
        hasFollowUpRequests = pendingFollowUps.isNotEmpty;
      });
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
                                      Icons.assignment_return_outlined,
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

                          // Use your existing table UI with the fetched data
                          return Scrollbar(
                            thumbVisibility: true,
                            thickness: 8,
                            child: SingleChildScrollView(
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
                                          'TECHNICIAN ASSIGNED',
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
                                  ],
                                  rows: scheduleData.map((data) {
                                    return DataRow(cells: [
                                      DataCell(Text(data.workOrderId)),
                                      DataCell(Text(data.technicianAssigned)),
                                      DataCell(Text(
                                        data.scheduledDate != null
                                            ? _formatDate(data.scheduledDate)
                                            : 'Not scheduled',
                                      )),
                                      DataCell(Text(data.scheduledTime)),
                                      DataCell(Text(data.estimatedHours)),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(data.status),
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
                                    ]);
                                  }).toList(),
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
    final followUpRequestsSnapshot = await FirebaseFirestore.instance
        .collection('PreliminaryReports')
        .where('followUps', isEqualTo: true)
        .get();

    // Get all work scheduling documents to check which follow-ups already have schedules
    final workSchedulingSnapshot =
        await FirebaseFirestore.instance.collection('WorkScheduling').get();

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
    setState(() {
      hasFollowUpRequests = pendingFollowUps.isNotEmpty;
    });

    if (pendingFollowUps.isEmpty) {
      // If there are no pending follow-up requests, show a message
      Toaster.showToast('No pending follow-up requests');
      return;
    }

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
                  builder: (context, prelimReportSnapshot) {
                    if (prelimReportSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0XFF7DBD2C),
                        ),
                      );
                    }

                    if (prelimReportSnapshot.hasError) {
                      return Text('Error: ${prelimReportSnapshot.error}');
                    }

                    if (!prelimReportSnapshot.hasData ||
                        prelimReportSnapshot.data!.docs.isEmpty) {
                      return Text('No follow-up requests found');
                    }

                    // Get all work scheduling documents to check for existing IDs
                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('WorkScheduling')
                          .get(),
                      builder: (context, workScheduleSnapshot) {
                        if (workScheduleSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Color(0XFF7DBD2C),
                            ),
                          );
                        }

                        if (workScheduleSnapshot.hasError) {
                          return Text('Error: ${workScheduleSnapshot.error}');
                        }

                        // Extract existing work order IDs
                        final Set<dynamic> existingWorkOrderIds =
                            workScheduleSnapshot.data != null
                                ? workScheduleSnapshot.data!.docs
                                    .map((doc) =>
                                        (doc.data() as Map<String, dynamic>)[
                                            'workOrderId'] ??
                                        '')
                                    .toSet()
                                : {};

                        // Filter preliminary reports to exclude those that already have work schedules
                        final filteredReports =
                            prelimReportSnapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final reportOrderId = data['orderId'] ?? '';
                          return !existingWorkOrderIds.contains(reportOrderId);
                        }).toList();

                        if (filteredReports.isEmpty) {
                          return Text('No new follow-up requests found');
                        }

                        return SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final doc = filteredReports[index];
                              final data = doc.data() as Map<String, dynamic>;

                              return Card(
                                margin: EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(
                                      'Order ID: ${data['orderId'] ?? ''}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Title: ${data['orderTitle'] ?? ''}'),
                                      Text(
                                          'Asset: ${data['assetSelection'] ?? ''}'),
                                      Text(
                                          'Findings: ${data['findings'] ?? ''}'),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0XFF7DBD2C),
                                    ),
                                    onPressed: () {
                                      // Create a work schedule from this request
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CreateWorkScheduling(
                                            prefilledData: {
                                              'workOrderId': data['orderId'],
                                              'assetSelection':
                                                  data['assetSelection'],
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Schedule',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close',
                        style: TextStyle(
                            color: Color(0XFF7DBD2C),
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
