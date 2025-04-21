import 'package:flutter/material.dart';
import 'package:ut_worx/screen_models/report_generator_model.dart';
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
    return ResponsiveLayout(builder: (context, responsives) {
      return Scaffold(
        backgroundColor: const Color(0XFFF4F7FE),
        drawer: const CustomDrawer(),
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(appBarHeight),
        //   child: CustomHeader(),
        // ),
        body: const ReportGenerator(),
      );
    });
  }
}

class ReportGenerator extends StatelessWidget {
  const ReportGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ReportGeneratorModel> reportData = [
      ReportGeneratorModel(
          workOrderId: 'Dog Trainer',
          assetId: 25486,
          completionDate: '12-02-2025',
          status: 'Completed'),
      ReportGeneratorModel(
          workOrderId: 'Nursing Assistant',
          assetId: 47893,
          completionDate: '15-02-2025',
          status: 'Pending'),
      ReportGeneratorModel(
          workOrderId: 'Vice President',
          assetId: 12478,
          completionDate: '22-02-2025',
          status: 'Rejected'),
      ReportGeneratorModel(
          workOrderId: 'BDR',
          assetId: 32789,
          completionDate: '02-02-2025',
          status: 'OnHold'),
      ReportGeneratorModel(
          workOrderId: 'SDR',
          assetId: 14789,
          completionDate: '25-02-2025',
          status: 'Pending'),
      ReportGeneratorModel(
          workOrderId: 'Product Owner',
          assetId: 24631,
          completionDate: '12-02-2025',
          status: 'Completed'),
      ReportGeneratorModel(
          workOrderId: 'CSM',
          assetId: 02483,
          completionDate: '01-03-2025',
          status: 'Pending'),
      ReportGeneratorModel(
          workOrderId: 'Account Executive',
          assetId: 80456,
          completionDate: '05-03-2025',
          status: 'Rejected'),
      ReportGeneratorModel(
          workOrderId: 'BDR',
          assetId: 40369,
          completionDate: '08-03-2025',
          status: 'Pending'),
    ];

    return ResponsiveLayout(builder: (context, responsive) {
      final titlePadding = responsive.deviceValue(
        mobile: 20.0,
        tablet: 20.0,
        desktop: 20.0,
      );
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

      final buttonPaddings = responsive.deviceValue(
        mobile: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        tablet: EdgeInsets.symmetric(horizontal: 6, vertical: 9),
        desktop: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      );
      final buttonSpacing = responsive.deviceValue(
        mobile: 4.0,
        tablet: 6.0,
        desktop: 8.0,
      );

      final bool useColumnLayout = responsive.isMobile;
      final bool usefullLayout = responsive.isTablet || responsive.isDesktop;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: useColumnLayout
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: titlePadding, right: titlePadding),
              child: useColumnLayout
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '  Report Generation',
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: buttonSpacing,
                          runSpacing: buttonSpacing,
                          children: [
                            _customButton("Select Date", Icons.calendar_month,
                                fontSize: buttonFontSize,
                                padding: buttonPaddings),
                            _customButton("Asset ID", Icons.keyboard_arrow_down,
                                fontSize: buttonFontSize,
                                padding: buttonPaddings),
                            _customButton(
                                "Work Status", Icons.keyboard_arrow_down,
                                fontSize: buttonFontSize,
                                padding: buttonPaddings),
                            _customButton("Export", Icons.keyboard_arrow_down,
                                color: Color(0XFF7DBD2C),
                                fontSize: buttonFontSize,
                                padding: buttonPaddings),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Report Generation',
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          children: [
                            _customButton("Select Date", Icons.calendar_month,
                                fontSize: buttonFontSize,
                                padding: buttonPaddings),
                            _customButton("Asset ID", Icons.keyboard_arrow_down,
                                fontSize: buttonFontSize,
                                padding: buttonPaddings),
                            _customButton(
                                "Work Status", Icons.keyboard_arrow_down,
                                fontSize: buttonFontSize,
                                padding: buttonPaddings),
                            _customButton("Export", Icons.keyboard_arrow_down,
                                color: Color(0XFF7DBD2C),
                                fontSize: buttonFontSize,
                                padding: buttonPaddings),
                          ],
                        ),
                      ],
                    ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width:
                        usefullLayout ? MediaQuery.sizeOf(context).width : 600,
                    child: DataTable(
                      columnSpacing: 20,
                      horizontalMargin: 15,
                      headingTextStyle: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: tableTitle),
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
                          'COMPLETION DATE',
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
                      ],
                      rows: reportData.map((data) {
                        return DataRow(cells: [
                          DataCell(Text(data.workOrderId)),
                          DataCell(Text(data.assetId.toString())),
                          DataCell(Text(data.completionDate)),
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
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _customButton(
    String text,
    IconData? icon, {
    Color color = Colors.white,
    double? fontSize,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          backgroundColor: color,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: color == Color(0XFF7DBD2C)
                    ? Colors.white
                    : Color(0XFF667085),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Icon(icon, color: Color(0XFF667085), size: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}
