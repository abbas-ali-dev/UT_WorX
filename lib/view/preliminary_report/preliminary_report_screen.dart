import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ut_worx/firebase_models/fb_preliminary_report_model.dart';
import 'package:ut_worx/utils/custom_widgets/custom_drawer.dart';
import 'package:ut_worx/utils/custom_widgets/custom_widgets.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';

class PreliminaryReportScreen extends StatelessWidget {
  const PreliminaryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(builder: (context, responsive) {
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
      final bool usefullLayout = responsive.isTablet || responsive.isDesktop;

      return Scaffold(
        backgroundColor: const Color(0XFFF4F7FE),
        drawer: const CustomDrawer(),
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(appBarHeight),
        //   child: CustomHeader(),
        // ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: titlePadding, right: titlePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Preliminary Report',
                        style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold)),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return const ReportDialog();
                    //       },
                    //     );
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     padding: EdgeInsets.zero,
                    //     backgroundColor: Color(0XFF7DBD2C),
                    //     foregroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   child: Padding(
                    //     padding: EdgeInsets.all(buttonPadding),
                    //     child: Text(
                    //       'Add Report',
                    //       style: TextStyle(fontSize: buttonFontSize),
                    //     ),
                    //   ),
                    // ),
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
                      .collection('PreliminaryReports')
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
                        child: Text('No preliminary reports found'),
                      );
                    }

                    // Convert Firestore documents to PreliminaryReport objects
                    final List<PreliminaryReport> reportData =
                        snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      DateTime? createdAt;
                      if (data['createdAt'] != null) {
                        createdAt = (data['createdAt'] as Timestamp).toDate();
                      }
                      return PreliminaryReport(
                        orderId: data['orderId'] ?? '',
                        orderTitle: data['orderTitle'] ?? '',
                        assetSelection: data['assetSelection'] ?? '',
                        findings: data['findings'] ?? '',
                        followUps: data['followUps'] ?? false,
                        createdBy: data['createdBy'] ?? '',
                        createdAt: createdAt,
                        imageData: data['imageData'] ?? '',
                        imageName: data['imageName'] ?? '',
                        status: data['status'] ?? 'Pending',
                      );
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
                              ))),
                              DataColumn(
                                  label: Expanded(
                                      child: Text(
                                'ORDER TITLE',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ))),
                              DataColumn(
                                  label: Expanded(
                                      child: Text(
                                'ASSET SELECTION',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ))),
                              DataColumn(
                                  label: Expanded(
                                      child: Text(
                                'FINDINGS',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ))),
                              DataColumn(
                                  label: Expanded(
                                      child: Text(
                                'FOLLOW UPS',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ))),
                              DataColumn(
                                  label: Expanded(
                                      child: Text(
                                'CREATED BY',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ))),
                              DataColumn(
                                  label: Expanded(
                                      child: Text(
                                'STATUS',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ))),
                              DataColumn(
                                  label: Expanded(
                                child: Text(
                                  'ACTIONS',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              )),
                            ],
                            rows: reportData.map((data) {
                              return DataRow(cells: [
                                DataCell(Text(data.orderId)),
                                DataCell(Text(data.orderTitle)),
                                DataCell(Text(data.assetSelection)),
                                DataCell(
                                  // Row(
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     SizedBox(
                                  //       width: 200,
                                  // child:
                                  Text(
                                    data.findings,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // IconButton(
                                //   padding: EdgeInsets.zero,
                                //   icon: Icon(Icons.edit,
                                //       size: 20, color: Color(0XFF7DBD2C)),
                                //   onPressed: () {
                                //     _showEditFindingsDialog(
                                //         context, data);
                                //   },
                                // ),
                                //     ],
                                //   ),
                                // ),
                                DataCell(
                                  Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: data.followUps,
                                      onChanged: (value) {
                                        FirebaseFirestore.instance
                                            .collection('PreliminaryReports')
                                            .doc(data.orderId)
                                            .update({
                                          'followUps': true,
                                        });
                                      },
                                      activeColor: Color(0XFF7DBD2C),
                                    ),
                                  ),
                                ),
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
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () {
                                      _showPreliminaryReportDetailsDialog(
                                          context, data);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0XFF7DBD2C),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      minimumSize: Size(60, 25),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // void _showEditFindingsDialog(BuildContext context, PreliminaryReport report) {
  //   final TextEditingController findingsController =
  //       TextEditingController(text: report.findings);

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: TextField(
  //           controller: findingsController,
  //           decoration: InputDecoration(
  //             hintText: 'Enter findings',
  //             border: OutlineInputBorder(),
  //           ),
  //           maxLines: 3,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: Color(0XFF7DBD2C),
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Color(0XFF7DBD2C),
  //             ),
  //             onPressed: () async {
  //               try {
  //                 await FirebaseFirestore.instance
  //                     .collection('PreliminaryReports')
  //                     .doc(report.orderId)
  //                     .update({
  //                   'findings': findingsController.text,
  //                 });

  //                 Navigator.of(context).pop();

  //                 Toaster.showToast('Findings updated successfully');
  //               } catch (e) {
  //                 Navigator.of(context).pop();
  //                 Toaster.showToast('Failed to update findings');
  //               }
  //             },
  //             child: Text(
  //               'Save',
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showPreliminaryReportDetailsDialog(
      BuildContext context, PreliminaryReport notification) {
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
                          'Preliminary Report Details',
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

                      // Asset Selection
                      buildDetailRow(
                        'Asset Selection:',
                        notification.assetSelection,
                        labelFontSize,
                        contentFontSize,
                      ),
                      SizedBox(height: 10),

                      // Findings
                      buildDetailRow(
                        'Findings:',
                        notification.findings,
                        labelFontSize,
                        contentFontSize,
                      ),
                      SizedBox(height: 10),

                      // Follow Ups
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Follow Ups:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: labelFontSize,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            notification.followUps ? 'Yes' : 'No',
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
