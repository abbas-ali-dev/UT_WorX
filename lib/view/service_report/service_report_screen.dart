// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ut_worx/utils/custom_widgets/custom_drawer.dart';
import 'package:ut_worx/utils/custom_widgets/custom_widgets.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';
import 'package:ut_worx/view/service_report/create_service_report.dart';

class ServiceReportScreen extends StatefulWidget {
  const ServiceReportScreen({super.key});

  @override
  State<ServiceReportScreen> createState() => _ServiceReportScreenState();
}

class _ServiceReportScreenState extends State<ServiceReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF4F7FE),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ServiceReportTable(),
          ],
        ),
      ),
    );
  }
}

class ServiceReportTable extends StatelessWidget {
  const ServiceReportTable({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
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
        final bool usefullLayout = responsive.isTablet || responsive.isDesktop;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: titlePadding, right: titlePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Service Report',
                    style: TextStyle(
                        fontSize: titleFontSize, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CreateServiceReport();
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
                        'Add Service Report',
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
                    .collection('PreliminaryReports')
                    .where('followUps', isEqualTo: false)
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
                      child: Text('No service reports found'),
                    );
                  }

                  // Convert the preliminary reports to service report models
                  final prelimReports = snapshot.data!.docs;

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
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'ORDER TITLE',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'ASSET SELECTION',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'FINDINGS',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'CREATED BY',
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
                                  'ACTIONS',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                          rows: prelimReports.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            return DataRow(cells: [
                              DataCell(Text(data['orderId'] ?? '')),
                              DataCell(Text(data['orderTitle'] ?? '')),
                              DataCell(Text(data['assetSelection'] ?? '')),
                              DataCell(Text(data['findings'] ?? '')),
                              DataCell(Text(data['createdBy'] ?? '')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(
                                        data['status'] ?? 'Pending'),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    data['status'] ?? 'Pending',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    _showCreateServiceReportDialog(
                                        context, data);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0XFF7DBD2C),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: const Size(60, 25),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text(
                                    'Create Report',
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
        );
      },
    );
  }

  // Method to show the create service report dialog with prefilled data
  void _showCreateServiceReportDialog(
      BuildContext context, Map<String, dynamic> prelimData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateServiceReport(
          prefilledData: {
            'workOrderId': prelimData['orderId'],
            'assetId': prelimData['assetSelection'],
            'prelimFindings': prelimData['findings'],
          },
        );
      },
    );
  }
}
