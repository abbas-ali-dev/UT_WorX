import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ut_worx/utils/custom_widgets/custom_button.dart';
import 'package:ut_worx/utils/custom_widgets/custom_drawer.dart';
import 'package:ut_worx/utils/custom_widgets/custom_graph_card.dart';
import 'package:ut_worx/view/dashboard/work_summary_table.dart';
import '../../utils/resposive_design/responsive_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Create separate controllers for each scrollable widget
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _tableScrollController = ScrollController();

  DateTime? selectedDate;

  @override
  void dispose() {
    _mainScrollController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(builder: (context, responsives) {
      final appBarHeight = responsives.deviceValue(
        mobile: 50.0,
        tablet: 70.0,
        desktop: 80.0,
      );
      return Scaffold(
        backgroundColor: const Color(0XFFF4F7FE),
        drawer: const CustomDrawer(),
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(appBarHeight),
        //   child: CustomHeader(),
        // ),
        body: ResponsiveLayout(
          builder: (context, responsive) {
            // Define responsive values
            final titleFontSize = responsive.deviceValue(
              mobile: 14.0,
              tablet: 18.0,
              desktop: 22.0,
            );

            final buttonFontSize = responsive.deviceValue(
              mobile: 9.0,
              tablet: 12.0,
              desktop: 14.0,
            );

            final cardPadding = responsive.deviceValue(
              mobile: 5.0,
              tablet: 12.0,
              desktop: 14.0,
            );

            final summaryCardFontSize = responsive.deviceValue(
              mobile: 12.0,
              tablet: 14.0,
              desktop: 17.0,
            );

            final summaryValueFontSize = responsive.deviceValue(
              mobile: 14.0,
              tablet: 18.0,
              desktop: 22.0,
            );

            final graphHeight = responsive.deviceValue(
              mobile: 150.0,
              tablet: 180.0,
              desktop: 200.0,
            );

            final bodyPadding = responsive.deviceValue(
              mobile: 8.0,
              tablet: 12.0,
              desktop: 16.0,
            );

            final buttonSpacing = responsive.deviceValue(
              mobile: 4.0,
              tablet: 6.0,
              desktop: 8.0,
            );

            final buttonPadding = responsive.deviceValue(
              mobile: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              tablet: EdgeInsets.symmetric(horizontal: 6, vertical: 9),
              desktop: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            );

            // Determine if we should use column layout for small screens
            final useColumnLayout = responsive.isMobile;

            return SingleChildScrollView(
              controller: _mainScrollController,
              child: Padding(
                padding: EdgeInsets.all(bodyPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Header section with work summary and buttons
                    if (useColumnLayout)
                      // Mobile layout - stack vertically
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "  Work Summary",
                            style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: buttonSpacing,
                            runSpacing: buttonSpacing,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    backgroundColor: Colors.white,
                                    padding: buttonPadding,
                                  ),
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: Icon(
                                            Icons.calendar_month_outlined,
                                            color: Color(0XFF667085),
                                            size: buttonFontSize),
                                      ),
                                      Text(
                                        selectedDate != null
                                            ? DateFormat('dd/MM/yyyy')
                                                .format(selectedDate!)
                                            : "Select Date",
                                        style: TextStyle(
                                          fontSize: buttonFontSize,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0XFF667085),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              customButton("Asset Type", false,
                                  fontSize: buttonFontSize,
                                  padding: buttonPadding),
                              customButton("View Reports", false,
                                  fontSize: buttonFontSize,
                                  padding: buttonPadding),
                              customButton("Add Work", false,
                                  color: Color(0XFF7DBD2C),
                                  fontSize: buttonFontSize,
                                  padding: buttonPadding),
                            ],
                          ),
                        ],
                      )
                    else
                      // Tablet/Desktop layout - side by side
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Work Summary",
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
                                    padding: buttonPadding,
                                  ),
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: Icon(
                                            Icons.calendar_month_outlined,
                                            color: Color(0XFF667085),
                                            size: buttonFontSize),
                                      ),
                                      Text(
                                        selectedDate != null
                                            ? DateFormat('dd/MM/yyyy')
                                                .format(selectedDate!)
                                            : "Select Date",
                                        style: TextStyle(
                                          fontSize: buttonFontSize,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0XFF667085),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              customButton("Asset Type", false,
                                  fontSize: buttonFontSize,
                                  padding: buttonPadding),
                              customButton("View Reports", false,
                                  fontSize: buttonFontSize,
                                  padding: buttonPadding),
                              customButton("Add Work", false,
                                  color: Color(0XFF7DBD2C),
                                  fontSize: buttonFontSize,
                                  padding: buttonPadding),
                            ],
                          ),
                        ],
                      ),

                    SizedBox(height: 16),

                    // Summary cards
                    if (useColumnLayout)
                      // Mobile layout - stack vertically
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _summaryCard("Task Completed Today", "20",
                              fontSize: summaryCardFontSize,
                              valueFontSize: summaryValueFontSize,
                              padding: cardPadding),
                          // SizedBox(height: 5),
                          _summaryCard("Task Pending Schedule", "12",
                              fontSize: summaryCardFontSize,
                              valueFontSize: summaryValueFontSize,
                              padding: cardPadding),
                          // SizedBox(height: 5),
                          _summaryCard("Task Pending Approval", "5",
                              fontSize: summaryCardFontSize,
                              valueFontSize: summaryValueFontSize,
                              padding: cardPadding),
                        ],
                      )
                    else
                      // Tablet/Desktop layout - side by side
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard("Task Completed Today", "20",
                                fontSize: summaryCardFontSize,
                                valueFontSize: summaryValueFontSize,
                                padding: cardPadding),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _summaryCard("Task Pending Schedule", "12",
                                fontSize: summaryCardFontSize,
                                valueFontSize: summaryValueFontSize,
                                padding: cardPadding),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _summaryCard("Task Pending Approval", "5",
                                fontSize: summaryCardFontSize,
                                valueFontSize: summaryValueFontSize,
                                padding: cardPadding),
                          ),
                        ],
                      ),

                    SizedBox(height: 16),

                    // Graph cards
                    if (useColumnLayout)
                      // Mobile layout - stack vertically
                      Column(
                        children: [
                          CustomGraphCard.graphCard("Asset Overview",
                              fontSize: summaryCardFontSize,
                              graphHeight: graphHeight,
                              padding: cardPadding),
                          SizedBox(height: 10),
                          CustomGraphCard.graphCard("Spare Part Consumption",
                              fontSize: summaryCardFontSize,
                              graphHeight: graphHeight,
                              padding: cardPadding,
                              isSecondGraph: true),
                        ],
                      )
                    else
                      // Tablet/Desktop layout - side by side
                      Row(
                        children: [
                          Expanded(
                            child: CustomGraphCard.graphCard("Asset Overview",
                                fontSize: summaryCardFontSize,
                                graphHeight: graphHeight,
                                padding: cardPadding),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: CustomGraphCard.graphCard(
                                "Spare Part Consumption",
                                fontSize: summaryCardFontSize,
                                graphHeight: graphHeight,
                                padding: cardPadding,
                                isSecondGraph: true),
                          ),
                        ],
                      ),

                    SizedBox(height: 16),

                    // Work summary table
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height - 400,
                      child: WorkSummaryTable(responsive: responsive),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
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

  Widget _summaryCard(
    String title,
    String value, {
    double? fontSize,
    double? valueFontSize,
    double? padding,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(padding ?? 16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: fontSize ?? 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: valueFontSize ?? 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
