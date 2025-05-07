import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ut_worx/constant/toaster.dart';
import 'package:ut_worx/firebase_models/fb_notification_model.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';

void showGenerateReportDialog(
    BuildContext context, NotificationModel notification) {
  // Controllers for the text fields
  final TextEditingController prelimFindingController = TextEditingController();
  final TextEditingController faultyComponentsController =
      TextEditingController();
  final TextEditingController immediateActionController =
      TextEditingController();
  final TextEditingController reportByController = TextEditingController();
  final TextEditingController prelimReportIdController =
      TextEditingController(text: 'PR-${notification.orderId}');

  // Default date to today
  DateTime selectedDate = DateTime.now();
  ValueNotifier<bool> requiredFollowUp = ValueNotifier<bool>(false);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
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
                        'Generate Preliminary Report',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Prelim Finding
                    Text(
                      'Prelim Finding:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: labelFontSize,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: prelimFindingController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter preliminary findings',
                      ),
                      style: TextStyle(fontSize: contentFontSize),
                    ),
                    SizedBox(height: 15),

                    // Faulty Components
                    Text(
                      'Faulty Components:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: labelFontSize,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: faultyComponentsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter faulty components',
                      ),
                      style: TextStyle(fontSize: contentFontSize),
                    ),
                    SizedBox(height: 15),

                    // Date
                    Text(
                      'Date:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: labelFontSize,
                      ),
                    ),
                    SizedBox(height: 5),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          selectedDate = picked;
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(fontSize: contentFontSize),
                            ),
                            Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Immediate Action
                    Text(
                      'Immediate Action:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: labelFontSize,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: immediateActionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter immediate action required',
                      ),
                      style: TextStyle(fontSize: contentFontSize),
                    ),
                    SizedBox(height: 15),

                    // Required Follow-up
                    Row(
                      children: [
                        Text(
                          'Required Follow-up:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: labelFontSize,
                          ),
                        ),
                        Spacer(),
                        ValueListenableBuilder<bool>(
                          valueListenable: requiredFollowUp,
                          builder: (context, value, child) {
                            return Switch(
                              value: value,
                              onChanged: (bool value) {
                                requiredFollowUp.value = value;
                              },
                              activeColor: Color(0XFF7DBD2C),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 15),

                    // Report by (ID)
                    Text(
                      'Report by (ID):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: labelFontSize,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: reportByController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter reporter ID',
                      ),
                      style: TextStyle(fontSize: contentFontSize),
                    ),
                    SizedBox(height: 15),

                    // Prelim_Report ID
                    Text(
                      'Prelim_Report ID:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: labelFontSize,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: prelimReportIdController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter preliminary report ID',
                      ),
                      style: TextStyle(fontSize: contentFontSize),
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
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: contentFontSize,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // Create preliminary report
                            _createPreliminaryReport(
                              context,
                              notification,
                              prelimFindingController.text,
                              faultyComponentsController.text,
                              selectedDate,
                              immediateActionController.text,
                              requiredFollowUp.value == true ? true : false,
                              reportByController.text,
                              prelimReportIdController.text,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0XFF7DBD2C),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Create Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: contentFontSize,
                            ),
                          ),
                        ),
                      ],
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

void _createPreliminaryReport(
  BuildContext context,
  NotificationModel notification,
  String prelimFinding,
  String faultyComponents,
  DateTime date,
  String immediateAction,
  bool requiredFollowUp,
  String reportBy,
  String prelimReportId,
) async {
  try {
    if (prelimFinding.isEmpty) {
      Toaster.showToast('Preliminary finding cannot be empty');
      return;
    }

    if (faultyComponents.isEmpty) {
      Toaster.showToast('Faulty components cannot be empty');
      return;
    }

    if (immediateAction.isEmpty) {
      Toaster.showToast('Immediate action cannot be empty');
      return;
    }

    if (reportBy.isEmpty) {
      Toaster.showToast('Report by (ID) cannot be empty');
      return;
    }
    EasyLoading.show();

    // Create preliminary report data
    Map<String, dynamic> preliminaryReportData = {
      'orderId': notification.orderId,
      'orderTitle': notification.orderTitle,
      'assetSelection': notification.assetSelection,
      'findings': prelimFinding,
      'faultyComponents': faultyComponents,
      'reportDate': Timestamp.fromDate(date),
      'immediateAction': immediateAction,
      'followUps': requiredFollowUp,
      'reportBy': reportBy,
      'prelimReportId': prelimReportId,
      'createdBy': notification.createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'Pending',
      'imageData': notification.imageData,
      'imageName': notification.imageName,
    };

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('PreliminaryReports')
        .doc(prelimReportId)
        .set(preliminaryReportData);

    EasyLoading.dismiss();

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

    Toaster.showToast('Preliminary report created successfully');
  } catch (e) {
    Toaster.showToast('Error creating preliminary report: $e');
  }
}
