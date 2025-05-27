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
  List<String> selectedSpareParts = [];

  // Lists for dropdowns - change this to store user objects with role info
  List<Map<String, dynamic>> technicians = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    try {
      // Load technicians from Firebase with role filtering
      final techniciansSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', whereIn: ['Operator', 'Technician']) // Filter by roles
          .get();

      setState(() {
        technicians = techniciansSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'email': data['email'] ?? '',
            'name': data['name'] ??
                data['email'] ??
                '', // Use name if available, else email
            'role': data['role'] ?? '',
            'uid': doc.id,
          };
        }).toList();
      });

      // Set default values
      selectedDate = DateTime.now().add(const Duration(days: 1));
      selectedTime = TimeOfDay.now();

      // Prefill data if available
      if (widget.prefilledData != null) {
        _workOrderIdController.text =
            widget.prefilledData!['workOrderId'] ?? '';
      } else {
        // Generate a unique ID if not prefilled
        _workOrderIdController.text = const Uuid().v4().substring(0, 8);
      }
    } catch (e) {
      debugPrint('Error loading technicians: $e');
      Toaster.showToast('Error loading technicians');
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

    if (selectedSpareParts.isEmpty) {
      Toaster.showToast('Please select at least one spare part');
      return;
    }

    // Show loading indicator
    EasyLoading.show(status: 'Creating work schedules...');

    try {
      // Get current user ID
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      // Get current date (without time)
      final DateTime currentDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      // Get selected date (without time)
      final DateTime targetDate = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );

      // Calculate difference in days
      final int daysDifference = targetDate.difference(currentDate).inDays;

      // Create a batch to perform multiple writes
      final batch = FirebaseFirestore.instance.batch();

      // Create work orders for each day from current date to selected date (inclusive)
      for (int i = 0; i <= daysDifference; i++) {
        // Calculate the date for this work order
        final DateTime orderDate = currentDate.add(Duration(days: i));

        // Create a unique ID for each work order
        final String workOrderId = i == 0
            ? _workOrderIdController.text
            : '${_workOrderIdController.text}_$i';

        // Create work scheduling data
        final Map<String, dynamic> workSchedulingData = {
          'workOrderId': workOrderId,
          'technicianAssigned': selectedTechnician,
          'scheduledDate': Timestamp.fromDate(orderDate),
          'scheduledTime': _formatTimeWithAmPm(selectedTime!),
          'estimatedHours': _estimatedHoursController.text,
          'status': 'Scheduled', // Default status
          'spareParts': selectedSpareParts,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Add to batch
        final docRef = FirebaseFirestore.instance
            .collection('WorkScheduling')
            .doc(workOrderId);
        batch.set(docRef, workSchedulingData);
      }

      // Commit the batch
      await batch.commit();

      // Hide loading indicator
      EasyLoading.dismiss();

      final String message = daysDifference > 0
          ? '${daysDifference + 1} work schedules created successfully'
          : 'Work schedule created successfully';
      Toaster.showToast(message);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      EasyLoading.dismiss();
      Toaster.showToast('Error: ${e.toString()}');
      debugPrint('Error creating work schedules: $e');
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

  void _showSparePartsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 400,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Spare Parts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children: getSparePartValues().map((sparePart) {
                            final isSelected =
                                selectedSpareParts.contains(sparePart);
                            return CheckboxListTile(
                              title: Text(sparePart.replaceAll('_', ' ')),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    selectedSpareParts.add(sparePart);
                                  } else {
                                    selectedSpareParts.remove(sparePart);
                                  }
                                });
                              },
                              activeColor: Color(0XFF7DBD2C),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.black)),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Update main dialog
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0XFF7DBD2C),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                    readOnly: widget.prefilledData != null,
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

                  // Technician Assignment - Updated dropdown
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
                      hintText: 'Select PIC (Operator/Technician)',
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
                    menuMaxHeight: 300,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTechnician = newValue;
                      });
                    },
                    items:
                        technicians.map<DropdownMenuItem<String>>((technician) {
                      return DropdownMenuItem<String>(
                        value: technician['email'],
                        child: Text(
                          '${technician['name']} (${technician['role']})',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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

                  // Spare Parts
                  Text(
                    'Spare Parts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),

                  InkWell(
                    onTap: _showSparePartsDialog,
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
                          Expanded(
                            child: Text(
                              selectedSpareParts.isEmpty
                                  ? 'Select Spare Parts'
                                  : '${selectedSpareParts.length} spare part(s) selected',
                              style: TextStyle(
                                color: selectedSpareParts.isEmpty
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down_outlined),
                        ],
                      ),
                    ),
                  ),
                  if (selectedSpareParts.isNotEmpty) ...[
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedSpareParts.map((sparePart) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0XFF7DBD2C),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  sparePart.replaceAll('_', ' '),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSpareParts.remove(sparePart);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

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
