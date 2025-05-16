import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../utils/resposive_design/responsive_layout.dart';
import '../../constant/toaster.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prelimFindingController =
      TextEditingController();
  final TextEditingController _assetController = TextEditingController();

  // State variables
  String workCategory = 'Select';
  String priority = 'Select';
  bool breakdownBypass = true;

  // Work category options
  final List<String> workCategories = [
    'FM',
    'PM',
    'PDM',
    'FPM',
    'FFM',
    'FPDM',
  ];

  // Priority options
  final List<String> priorities = ['Low', 'Medium', 'High', 'Critical'];

  // Add these variables
  final ImagePicker _picker = ImagePicker();
  String? _base64Image;
  String? _imageName;
  bool _isImageSelected = false;

  final Map<String, List<String>> _hardcodedData = {
    'L1': [
      'L1 Item 1: Equipment details',
      'L1 Item 2: Maintenance history',
      'L1 Item 3: Last service date'
    ],
    'L2': [
      'L2 Item 1: Component information',
      'L2 Item 2: Installation date',
      'L2 Item 3: Warranty status'
    ],
    'L3': [
      'L3 Item 1: Technical specifications',
      'L3 Item 2: Operating parameters',
      'L3 Item 3: Performance metrics'
    ],
    'L4': [
      'L4 Item 1: Safety guidelines',
      'L4 Item 2: Inspection records',
      'L4 Item 3: Compliance status'
    ],
    'L5': [
      'L5 Item 1: Spare parts inventory',
      'L5 Item 2: Supplier contacts',
      'L5 Item 3: Ordering information'
    ],
    'L6': [
      'L6 Item 1: Troubleshooting steps',
      'L6 Item 2: Common issues',
      'L6 Item 3: Resolution procedures'
    ],
  };

  List<bool> _expandedItems = [];
  @override
  void initState() {
    super.initState();
    _expandedItems = List<bool>.filled(_hardcodedData.length, false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assetController.dispose();
    super.dispose();
  }

  // Function to submit notification to Firebase
  Future<void> _submitNotification() async {
    // Validate inputs
    if (_titleController.text.isEmpty) {
      Toaster.showToast('Please enter a work order title');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      Toaster.showToast('Please enter a description');
      return;
    }
    // if (_prelimFindingController.text.isEmpty) {
    //   Toaster.showToast('Please enter a preliminary finding');
    //   return;
    // }

    if (_assetController.text.isEmpty) {
      Toaster.showToast('Please select an asset');
      return;
    }

    if (workCategory == 'Select') {
      Toaster.showToast('Please select a work category');
      return;
    }

    if (priority == 'Select') {
      Toaster.showToast('Please select a priority');
      return;
    }

    // Show loading indicator
    EasyLoading.show(status: 'Creating notification...');

    try {
      // Generate a unique ID
      final String orderId = const Uuid().v1().substring(0, 8);

      // Get current user email
      final String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      // Create notification data
      final Map<String, dynamic> notificationData = {
        'orderId': orderId,
        'orderTitle': _titleController.text,
        'description': _descriptionController.text,
        // 'prelimFinding': _prelimFindingController.text,
        'assetSelection': _assetController.text,
        'workCategory': workCategory,
        'priority': priority,
        'breakdownBypass': breakdownBypass,
        'createdBy': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Pending', // Default status
        // Add the base64 image if available
        'imageData': _base64Image,
        'imageName': _imageName,
      };

      // Create preliminary report data
      // final Map<String, dynamic> preliminaryReportData = {
      //   'orderId': orderId,
      //   'orderTitle': _titleController.text,
      //   'findings': null,
      //   'assetSelection': _assetController.text,
      //   'followUps': false,
      //   'createdBy': userEmail,
      //   'createdAt': FieldValue.serverTimestamp(),
      //   'status': 'Pending', // Default status
      //   // Add the base64 image if available
      //   'imageData': _base64Image,
      //   'imageName': _imageName,
      // };

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('Notifications')
          .doc(orderId)
          .set(notificationData);

      // await FirebaseFirestore.instance
      //     .collection('PreliminaryReports')
      //     .doc(orderId)
      //     .set(preliminaryReportData);

      // Hide loading indicator
      EasyLoading.dismiss();

      Toaster.showToast('Notification created successfully');

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      EasyLoading.dismiss();
      Toaster.showToast('Error: ${e.toString()}');
      debugPrint('Error creating notification: $e');
    }
  }

  // Method to show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.gallery);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to pick image from gallery or camera
  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Web platform handling
          final bytes = await pickedFile.readAsBytes();
          final base64String = base64Encode(bytes);
          setState(() {
            _base64Image = base64String;
            _imageName = pickedFile.name;
            _isImageSelected = true;
          });
        } else {
          // Mobile platform handling
          final bytes = await File(pickedFile.path).readAsBytes();
          final base64String = base64Encode(bytes);
          setState(() {
            _base64Image = base64String;
            _imageName = pickedFile.name;
            _isImageSelected = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Toaster.showToast('Error selecting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> expandedLabels = [
      'Label 1',
      'Label 2',
      'Label 3'
    ]; // Added definition
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
                    'Create Notification',
                    style: TextStyle(
                        fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: verticalSpacing * 2),
                  Text(
                    'Order Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Please add title',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
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
                    autovalidateMode: AutovalidateMode.always,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Fault Observation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: responsive.deviceValue(
                      mobile: 2,
                      tablet: 3,
                      desktop: 3,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Please add fault observation',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
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
                    autovalidateMode: AutovalidateMode.always,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Asset Selection',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _assetController,
                    decoration: InputDecoration(
                      hintText: 'Please select asset',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
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
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Upload Attachments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0XFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isImageSelected
                                ? _imageName ?? 'Image selected'
                                : 'Upload',
                            style: TextStyle(
                              color:
                                  _isImageSelected ? Colors.black : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cloud_upload_outlined),
                          onPressed: _showImageSourceDialog,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Work Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: workCategory == 'Select' ? null : workCategory,
                    decoration: InputDecoration(
                      hintText: 'Select',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
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
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down_outlined),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        workCategory = newValue ?? 'Select';
                      });
                    },
                    items: workCategories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Priority',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: priority == 'Select' ? null : priority,
                    decoration: InputDecoration(
                      hintText: 'Select',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Color(0XFFE5E7EB), width: 1)),
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
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down_outlined),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        priority = newValue ?? 'Select';
                      });
                    },
                    items: priorities
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: verticalSpacing),
                  Row(
                    children: [
                      Text(
                        'Breakdown/Bypass',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: labelFontSize,
                        ),
                      ),
                      const Spacer(),
                      Checkbox(
                        value: breakdownBypass,
                        activeColor: Color(0XFF7DBD2C),
                        onChanged: (bool? newValue) {
                          setState(() {
                            if (newValue != null) {
                              breakdownBypass = newValue;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  ExpansionPanelList(
                    elevation: 2,
                    expandedHeaderPadding: EdgeInsets.zero,
                    dividerColor: Colors.grey[300],
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _expandedItems[index] = !_expandedItems[index];
                      });
                    },
                    children: expandedLabels
                        .asMap()
                        .entries
                        .map<ExpansionPanel>((entry) {
                      int idx = entry.key;
                      String label = entry.value;
                      return ExpansionPanel(
                        backgroundColor: Colors.white,
                        canTapOnHeader: true,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(
                              label,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                        body: Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _hardcodedData.containsKey(label)
                                ? _hardcodedData[label]!.map((item) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(item),
                                    );
                                  }).toList()
                                : [Text("No data available for $label")],
                          ),
                        ),
                        isExpanded: _expandedItems[idx],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: verticalSpacing * 2),
                  // Use column for mobile, row for tablet and desktop
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
        await _submitNotification();
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
