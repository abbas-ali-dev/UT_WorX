import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ut_worx/firebase_models/fb_report_generation_model.dart';
import 'package:ut_worx/utils/custom_widgets/custom_drawer.dart';
import 'package:ut_worx/utils/custom_widgets/custom_widgets.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';

class ReportGeneratorScreen extends StatefulWidget {
  const ReportGeneratorScreen({super.key});

  @override
  State<ReportGeneratorScreen> createState() => _ReportGeneratorScreenState();
}

class _ReportGeneratorScreenState extends State<ReportGeneratorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF4F7FE),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: ReportGenerator(),
      ),
    );
  }
}

class ReportGenerator extends StatefulWidget {
  const ReportGenerator({super.key});

  @override
  State<ReportGenerator> createState() => _ReportGeneratorState();
}

class _ReportGeneratorState extends State<ReportGenerator> {
  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, responsive) {
        final titleFontSize = responsive.deviceValue(
          mobile: 14.0,
          tablet: 18.0,
          desktop: 22.0,
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
        final titlePadding = responsive.deviceValue(
          mobile: 20.0,
          tablet: 20.0,
          desktop: 20.0,
        );
        final bool usefullLayout = responsive.isTablet || responsive.isDesktop;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: titlePadding, right: titlePadding, top: 20),
              child: usefullLayout
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Report Generation',
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await _selectDate(context);
                              },
                              child: _customButton(
                                  context, 'Select Date', Icons.calendar_today),
                            ),
                            const SizedBox(width: 10),
                            _customButton(
                                context, 'Asset ID', Icons.arrow_drop_down),
                            const SizedBox(width: 10),
                            _customButton(
                                context, 'Work Status', Icons.arrow_drop_down),
                            const SizedBox(width: 10),
                            _customButton(
                                context, 'Export', Icons.arrow_drop_down,
                                color: const Color(0XFF7DBD2C)),
                          ],
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Generation',
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await _selectDate(context);
                              },
                              child: _customButton(
                                  context, 'Select Date', Icons.calendar_today),
                            ),
                            const SizedBox(height: 10),
                            _customButton(
                                context, 'Asset ID', Icons.arrow_drop_down),
                            const SizedBox(height: 10),
                            _customButton(
                                context, 'Work Status', Icons.arrow_drop_down),
                            const SizedBox(height: 10),
                            _customButton(
                                context, 'Export', Icons.arrow_drop_down,
                                color: const Color(0XFF7DBD2C)),
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
                      child: Text('No reports found'),
                    );
                  }

                  // Convert Firestore documents to ReportModel objects
                  final List<ReportModel> reports = snapshot.data!.docs
                      .map((doc) => ReportModel.fromFirestore(
                          doc.data() as Map<String, dynamic>))
                      .toList();

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
                          // ignore: deprecated_member_use
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
                                  'FOLLOW UPS',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'COMPLETION DATE',
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
                          rows: reports.map((report) {
                            // Format the createdAt timestamp
                            String formattedDate = 'N/A';
                            if (report.createdAt != null) {
                              formattedDate = DateFormat('dd/MM/yyyy')
                                  .format(report.createdAt!);
                            }

                            return DataRow(cells: [
                              DataCell(Text(report.orderId)),
                              DataCell(Text(report.orderTitle)),
                              DataCell(Text(report.followUps.toString())),
                              DataCell(Text(formattedDate)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(report.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    report.status,
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
                                    _showReportDetailsDialog(context, report);
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
        );
      },
    );
  }

  Widget _customButton(BuildContext context, String title, IconData icon,
      {Color color = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color == Colors.white ? Colors.black : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              icon,
              size: 18,
              color: color == Colors.white ? Colors.black : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Method to show the report details dialog
  void _showReportDetailsDialog(BuildContext context, ReportModel report) {
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
                Center(
                  child: Text(
                    'Report Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildDetailRow('Order ID', report.orderId),
                _buildDetailRow('Order Title', report.orderTitle),
                _buildDetailRow('Asset Selection', report.assetSelection),
                _buildDetailRow('Findings', report.findings),
                _buildDetailRow('Follow Ups', report.followUps ? 'Yes' : 'No'),
                _buildDetailRow('Status', report.status),

                // Format and display the createdAt timestamp
                _buildDetailRow(
                    'Created Date', _formatDateTime(report.createdAt)),
                _buildDetailRow('Created By', report.createdBy),

                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF7DBD2C),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0XFF7DBD2C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Helper method to format DateTime
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
