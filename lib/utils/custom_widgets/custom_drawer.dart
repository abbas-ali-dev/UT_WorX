import 'package:flutter/material.dart';
import 'package:ut_worx/resources/firebase_auth_method.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';
import 'package:ut_worx/view/auth/login_screen.dart';
import 'package:ut_worx/view/auth/signup_screen.dart';
import 'package:ut_worx/view/dashboard/dashboard_screen.dart';
import 'package:ut_worx/view/my_task/my_task.dart';
import 'package:ut_worx/view/notification_creation/notification_screen.dart';
import 'package:ut_worx/view/pms/pms_screen.dart';
import 'package:ut_worx/view/preliminary_report/preliminary_report_screen.dart';
import 'package:ut_worx/view/report_generation/report_generation_screen.dart';
import 'package:ut_worx/view/service_report/service_report_screen.dart';
import 'package:ut_worx/view/work_scheduling/work_scheduling_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, responsive) {
        final logoHeight = responsive.deviceValue(
          mobile: 60.0,
          tablet: 70.0,
          desktop: 80.0,
        );

        final iconSize = responsive.deviceValue(
          mobile: 20.0,
          tablet: 22.0,
          desktop: 24.0,
        );

        final fontSize = responsive.deviceValue(
          mobile: 13.0,
          tablet: 14.0,
          desktop: 15.0,
        );

        final drawerWidth = responsive.deviceValue(
          mobile: 220.0,
          tablet: 260.0,
          desktop: 280.0,
        );

        return SizedBox(
          width: drawerWidth,
          child: Drawer(
            backgroundColor: Colors.white,
            child: Column(
              children: [
                Container(
                  height: logoHeight + 40,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide.none),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: logoHeight,
                    ),
                  ),
                ),

                const Divider(
                  color: Color(0XFFA3AED0),
                  thickness: 1,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _drawerItem(
                        Icons.dashboard,
                        "Dashboard",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(),
                            ),
                          );
                        },
                      ),
                      _drawerItem(
                        Icons.create_outlined,
                        "Notification Creation",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationListScreen(),
                            ),
                          );
                        },
                      ),
                      _drawerItem(
                        Icons.description_outlined,
                        "Preliminary Report",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PreliminaryReportScreen(),
                            ),
                          );
                        },
                      ),
                      _drawerItem(
                        Icons.calendar_today_outlined,
                        "Work Scheduling",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WorkSchedulingScreen(),
                            ),
                          );
                        },
                      ),
                      _drawerItem(
                        Icons.insert_chart_outlined_outlined,
                        "Service Report",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ServiceReportScreen(),
                            ),
                          );
                        },
                      ),
                      _drawerItem(
                        Icons.task_outlined,
                        "Report Generation",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ReportGeneratorScreen(),
                            ),
                          );
                        },
                      ),
                      _drawerItem(
                        Icons.inventory_outlined,
                        "My Task",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyTaskScreen(),
                            ),
                          );
                        },
                      ),
                      _drawerItem(
                        Icons.alarm,
                        "PM Scheduler",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PMSScreen(),
                            ),
                          );
                        },
                      ),
                      _drawerItem(
                        Icons.person_add_alt,
                        "Create New User",
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTapAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Add logout item at the bottom
                _drawerItem(
                  Icons.logout,
                  "Logout",
                  iconSize: iconSize,
                  fontSize: fontSize,
                  onTapAction: () async {
                    await FirebaseAuthMethods().signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title, {
    double? iconSize,
    double? fontSize,
    VoidCallback? onTapAction,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Color(0XFFA3AED0),
        size: iconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          color: Color(0XFFA3AED0),
        ),
      ),
      onTap: onTapAction ?? () {},
    );
  }
}
