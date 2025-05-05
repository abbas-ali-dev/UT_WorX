import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:ut_worx/constant/enums.dart';
import 'package:uuid/uuid.dart';
import 'package:ut_worx/constant/toaster.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';

class CreateWorkScheduling extends StatefulWidget {
  final Map<String, dynamic>? prefilledData;

  const CreateWorkScheduling({
    super.key,
    this.prefilledData,
  });

  @override
  State<CreateWorkScheduling> createState() => _CreateWorkSchedulingState();
}

class _CreateWorkSchedulingState extends State<CreateWorkScheduling> {
  // Form controllers
  final TextEditingController _workOrderIdController = TextEditingController();
  final TextEditingController _estimatedHoursController =
      TextEditingController();

  // Selected values
  String? selectedTechnician;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedSparePart; // Changed to String type

  // Lists for dropdowns
  final List<String> technicians = [
    'John Doe',
    'Jane Smith',
    'Robert Johnson',
    'Emily Davis',
    'Michael Wilson'
  ];

  @override
  void initState() {
    super.initState();

    // Set default values
    selectedDate = DateTime.now().add(const Duration(days: 1));
    selectedTime = TimeOfDay.now();

    // Prefill data if available
    if (widget.prefilledData != null) {
      _workOrderIdController.text = widget.prefilledData!['workOrderId'] ?? '';
      // You can prefill other fields as needed
    } else {
      // Generate a unique ID if not prefilled
      _workOrderIdController.text = const Uuid().v4().substring(0, 8);
    }
  }

  @override
  void dispose() {
    _workOrderIdController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  // Function to submit work scheduling to Firebase
  Future<void> _submitWorkScheduling() async {
    // Validate inputs
    if (_workOrderIdController.text.isEmpty) {
      Toaster.showToast('Please enter a work order ID');
      return;
    }

    if (selectedTechnician == null) {
      Toaster.showToast('Please select a technician');
      return;
    }

    if (selectedDate == null) {
      Toaster.showToast('Please select a date');
      return;
    }

    if (_estimatedHoursController.text.isEmpty) {
      Toaster.showToast('Please enter estimated hours');
      return;
    }

    // Add this validation
    if (selectedSparePart == null || selectedSparePart!.isEmpty) {
      Toaster.showToast('Please select a spare part');
      return;
    }

    // Show loading indicator
    EasyLoading.show(status: 'Creating work schedule...');

    try {
      // Get current user ID
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      // Create work scheduling data
      final Map<String, dynamic> workSchedulingData = {
        'workOrderId': _workOrderIdController.text,
        'technicianAssigned': selectedTechnician,
        'scheduledDate': Timestamp.fromDate(selectedDate!),
        'scheduledTime': _formatTimeWithAmPm(selectedTime!),
        'estimatedHours': _estimatedHoursController.text,
        'status': 'Scheduled', // Default status
        'sparePart': selectedSparePart,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('WorkScheduling')
          .doc(_workOrderIdController.text)
          .set(workSchedulingData);

      // Hide loading indicator
      EasyLoading.dismiss();

      Toaster.showToast('Work schedule created successfully');

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      EasyLoading.dismiss();
      Toaster.showToast('Error: ${e.toString()}');
      debugPrint('Error creating work schedule: $e');
    }
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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

  // Function to show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0XFF7DBD2C),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Helper method to format time with AM/PM
  String _formatTimeWithAmPm(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute
        .toString()
        .padLeft(2, '0'); // Ensure minutes have leading zero
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Helper method to get enum values as strings
  List<String> getSparePartValues() {
    return SparePart.values
        .map((part) => part.toString().split('.').last)
        .toList();
  }

  // Helper method to convert string back to enum
  SparePart? getSparePartFromString(String? value) {
    if (value == null) return null;
    return SparePart.values.firstWhere(
      (part) => part.toString().split('.').last == value,
      orElse: () => SparePart.values.first,
    );
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

          final buttonPadding = responsive.deviceValue(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
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
                    'Create Work Schedule',
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
                        null, // Make it read-only if prefilled
                    decoration: InputDecoration(
                      hintText: 'Work Order ID',
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

                  // Technician Assignment
                  Text(
                    'Assign PIC',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: selectedTechnician,
                    decoration: InputDecoration(
                      hintText: 'Select PIC',
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
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down_outlined),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTechnician = newValue;
                      });
                    },
                    items: technicians
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Schedule Date
                  Text(
                    'Schedule Date',
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
                                ? DateFormat('MMM dd, yyyy')
                                    .format(selectedDate!)
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

                  // Time Selection
                  Text(
                    'Schedule Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () => _selectTime(context),
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
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : 'Select Time',
                            style: TextStyle(
                              color: selectedTime != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                          Icon(Icons.access_time, color: Color(0XFF7DBD2C)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Estimated Hours
                  Text(
                    'Estimated Completion Hours',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _estimatedHoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter hours',
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

                  // Spare Part Selection
                  Text(
                    'Spare Part',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: selectedSparePart,
                    decoration: InputDecoration(
                      hintText: 'Select Spare Part',
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
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down_outlined),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSparePart = newValue;
                      });
                    },
                    items: getSparePartValues()
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        // Display the value with spaces instead of underscores
                        child: Text(value.replaceAll('_', ' ')),
                      );
                    }).toList(),
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
        await _submitWorkScheduling();
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
