import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ut_worx/constant/toaster.dart';
import 'package:ut_worx/utils/custom_widgets/custom_drawer.dart';
import 'package:ut_worx/utils/custom_widgets/custom_widgets.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';

class MyTaskScreen extends StatefulWidget {
  const MyTaskScreen({super.key});

  @override
  State<MyTaskScreen> createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF4F7FE),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: MyTaskContent(),
      ),
    );
  }
}

class MyTaskContent extends StatefulWidget {
  const MyTaskContent({super.key});

  @override
  State<MyTaskContent> createState() => _MyTaskContentState();
}

class _MyTaskContentState extends State<MyTaskContent> {
  final _user = FirebaseAuth.instance.currentUser;

  DateTime? selectedDate;
  // Add scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  // Dispose controllers when widget is disposed
  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

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
                          'My Tasks',
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                ),
                                onPressed: () {
                                  _selectDate(context);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Icon(Icons.calendar_month_outlined,
                                          color: Color(0XFF667085), size: 14),
                                    ),
                                    Text(
                                      selectedDate != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(selectedDate!)
                                          : "Select Date",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0XFF667085),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _customButton("Status", Icons.arrow_drop_down),
                          ],
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Tasks',
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                ),
                                onPressed: () {
                                  _selectDate(context);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Icon(Icons.calendar_month_outlined,
                                          color: Color(0XFF667085), size: 12),
                                    ),
                                    Text(
                                      selectedDate != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(selectedDate!)
                                          : "Select Date",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0XFF667085),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _customButton("Status", Icons.arrow_drop_down),
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
                    // .orderBy('createdAt', descending: true)
                    .where('technicianAssigned', isEqualTo: _user!.email)
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
                      child: Text('No tasks found'),
                    );
                  }

                  final tasks = snapshot.data!.docs;

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
                                      "TECHNICIAN ASSIGNED",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'DUE DATE',
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
                              rows: tasks.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;

                                // Format the date
                                String formattedDate = 'N/A';
                                if (data['scheduledDate'] != null) {
                                  try {
                                    final dueDate =
                                        (data['scheduledDate'] as Timestamp)
                                            .toDate();
                                    formattedDate = DateFormat('dd/MM/yyyy')
                                        .format(dueDate);
                                  } catch (e) {
                                    formattedDate = 'Invalid Date';
                                  }
                                }

                                return DataRow(cells: [
                                  DataCell(Text(data['workOrderId'] ?? 'N/A')),
                                  DataCell(Text(
                                      data['technicianAssigned'] ?? 'N/A')),
                                  DataCell(Text(formattedDate)),
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
                                    data['status'] == 'Completed'
                                        ? Text(
                                            'Done',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : PopupMenuButton<String>(
                                            color: Color(0XFF7DBD2C),
                                            icon: Icon(Icons.more_vert,
                                                color: Colors.grey),
                                            onSelected: (String value) async {
                                              if (value == 'completed') {
                                                // Update the status to 'Completed' in Firestore
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        'WorkScheduling')
                                                    .doc(doc.id)
                                                    .update({
                                                  'status': 'Completed'
                                                });

                                                Toaster.showToast(
                                                    'Task completed');
                                              } else if (value == 'start') {
                                                // Update the status to 'In Progress' in Firestore
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        'WorkScheduling')
                                                    .doc(doc.id)
                                                    .update({
                                                  'status': 'In Progress'
                                                });

                                                Toaster.showToast(
                                                    'Task started');
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'start',
                                                child: Text(
                                                  'Start',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'completed',
                                                child: Text(
                                                  'Completed',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
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
    );
  }

  Widget _customButton(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0XFF667085),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              icon,
              size: 18,
              color: Color(0XFF667085),
            ),
          ],
        ),
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
}
