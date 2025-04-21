import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:ut_worx/constant/enums.dart';
import 'package:ut_worx/constant/toaster.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';
import 'package:uuid/uuid.dart';

class CreateServiceReport extends StatefulWidget {
  final Map<String, dynamic>? prefilledData;

  const CreateServiceReport({super.key, this.prefilledData});

  @override
  State<CreateServiceReport> createState() => _CreateServiceReportState();
}

class _CreateServiceReportState extends State<CreateServiceReport> {
  final TextEditingController _workOrderIdController = TextEditingController();
  final TextEditingController _assetIdController = TextEditingController();
  final TextEditingController _finalFindingsController =
      TextEditingController();
  final TextEditingController _sparePartsController = TextEditingController();
  final TextEditingController _technicianController = TextEditingController();

  DateTime? selectedDate;
  SparePart? _selectedSparePart;

  @override
  void initState() {
    super.initState();

    // Set default date to today
    selectedDate = DateTime.now();

    // Prefill data if available
    if (widget.prefilledData != null) {
      _workOrderIdController.text = widget.prefilledData!['workOrderId'] ?? '';
      _assetIdController.text = widget.prefilledData!['assetId'] ?? '';

      // If preliminary findings are provided, use them as a starting point
      if (widget.prefilledData!['prelimFindings'] != null) {
        _finalFindingsController.text =
            'Based on preliminary findings: ${widget.prefilledData!['prelimFindings']}';
      }
    }
  }

  @override
  void dispose() {
    _workOrderIdController.dispose();
    _assetIdController.dispose();
    _finalFindingsController.dispose();
    _sparePartsController.dispose();
    _technicianController.dispose();
    super.dispose();
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to submit service report
  Future<void> _submitServiceReport() async {
    // Validate inputs
    if (_workOrderIdController.text.isEmpty) {
      Toaster.showToast('Please enter a work order ID');
      return;
    }

    if (_assetIdController.text.isEmpty) {
      Toaster.showToast('Please enter an asset ID');
      return;
    }

    if (_finalFindingsController.text.isEmpty) {
      Toaster.showToast('Please enter final findings');
      return;
    }

    if (_sparePartsController.text.isEmpty) {
      Toaster.showToast('Please enter spare parts used');
      return;
    }

    if (_selectedSparePart == null) {
      Toaster.showToast('Please select spare parts used');
      return;
    }

    if (_technicianController.text.isEmpty) {
      Toaster.showToast('Please enter technician name');
      return;
    }

    if (selectedDate == null) {
      Toaster.showToast('Please select a completion date');
      return;
    }

    // Show loading indicator
    EasyLoading.show(status: 'Creating service report...');

    try {
      // Generate a unique ID
      final String reportId = const Uuid().v4();

      // Get current user email
      final String userEmail =
          FirebaseAuth.instance.currentUser?.email ?? 'unknown';

      // Create service report data
      final Map<String, dynamic> serviceReportData = {
        'reportId': reportId,
        'workOrderId': _workOrderIdController.text,
        'assetId': _assetIdController.text,
        'finalFindings': _finalFindingsController.text,
        'sparePartsUsed': _sparePartsController.text,
        'completionDate': Timestamp.fromDate(selectedDate!),
        'technician': _technicianController.text,
        'createdBy': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Completed',
      };

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('ServiceReports')
          .doc(reportId)
          .set(serviceReportData);

      // Update the status of the preliminary report to 'Completed'
      await FirebaseFirestore.instance
          .collection('PreliminaryReports')
          .where('orderId', isEqualTo: _workOrderIdController.text)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({
            'status': 'Completed',
          });
        }
      });

      // Update the status of the work scheduling if it exists
      await FirebaseFirestore.instance
          .collection('WorkScheduling')
          .where('workOrderId', isEqualTo: _workOrderIdController.text)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({
            'status': 'Completed',
          });
        }
      });

      // Hide loading indicator
      EasyLoading.dismiss();

      Toaster.showToast('Service report created successfully');

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      EasyLoading.dismiss();
      Toaster.showToast('Error: ${e.toString()}');
      debugPrint('Error creating service report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ResponsiveLayout(
        builder: (context, responsive) {
          // Get responsive values based on device type
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

          final verticalSpacing = responsive.deviceValue(
            mobile: 8.0,
            tablet: 10.0,
            desktop: 12.0,
          );

          return Container(
            width: dialogWidth,
            padding: EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Service Report',
                    style: TextStyle(
                        fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: verticalSpacing * 2),

                  // Work Order ID
                  Text(
                    'Work Order ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _workOrderIdController,
                    readOnly: widget.prefilledData !=
                        null, // Make read-only if prefilled
                    decoration: InputDecoration(
                      hintText: 'Enter work order ID',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
                      filled: true,
                      fillColor: widget.prefilledData != null
                          ? Colors.grey[100]
                          : Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: responsive.deviceValue(
                          mobile: 8.0,
                          tablet: 10.0,
                          desktop: 12.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Asset ID
                  Text(
                    'Asset ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _assetIdController,
                    readOnly: widget.prefilledData !=
                        null, // Make read-only if prefilled
                    decoration: InputDecoration(
                      hintText: 'Enter asset ID',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
                      filled: true,
                      fillColor: widget.prefilledData != null
                          ? Colors.grey[100]
                          : Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Final Findings
                  Text(
                    'Final Findings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _finalFindingsController,
                    maxLines: responsive.deviceValue(
                      mobile: 3,
                      tablet: 4,
                      desktop: 5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter final findings',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: responsive.deviceValue(
                          mobile: 8.0,
                          tablet: 10.0,
                          desktop: 12.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Spare Parts Used
                  Text(
                    'Spare Parts Used',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<SparePart>(
                    value: _selectedSparePart,
                    decoration: InputDecoration(
                      hintText: 'Select spare parts used',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: SparePart.values.map((SparePart part) {
                      return DropdownMenuItem<SparePart>(
                        value: part,
                        child: Text(part
                            .toString()
                            .split('.')
                            .last
                            .replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (SparePart? newValue) {
                      setState(() {
                        _selectedSparePart = newValue;
                        if (newValue != null) {
                          _sparePartsController.text = newValue
                              .toString()
                              .split('.')
                              .last
                              .replaceAll('_', ' ');
                        }
                      });
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  // Completion Date
                  Text(
                    'Completion Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0XFFE5E7EB)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                : 'Select Date',
                            style: TextStyle(
                              color: selectedDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: Color(0XFF7DBD2C)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Technician
                  Text(
                    'Technician',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _technicianController,
                    decoration: InputDecoration(
                      hintText: 'Enter technician name',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 2),
                  // Buttons
                  responsive.isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCancelButton(context, responsive),
                            SizedBox(height: verticalSpacing),
                            _buildSubmitButton(context, responsive),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: _buildCancelButton(context, responsive)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildSubmitButton(context, responsive)),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, ResponsiveInfo responsive) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        side: BorderSide(color: Color(0XFFE5E7EB)),
        padding: EdgeInsets.symmetric(
          horizontal: 25,
          vertical: responsive.deviceValue(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'Cancel',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: responsive.deviceValue(
            mobile: 14.0,
            tablet: 15.0,
            desktop: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ResponsiveInfo responsive) {
    return ElevatedButton(
      onPressed: () async {
        await _submitServiceReport();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0XFF7DBD2C),
        padding: EdgeInsets.symmetric(
          horizontal: 25,
          vertical: responsive.deviceValue(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'Submit',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: responsive.deviceValue(
            mobile: 14.0,
            tablet: 15.0,
            desktop: 16.0,
          ),
        ),
      ),
    );
  }
}
