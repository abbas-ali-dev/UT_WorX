import 'package:flutter/material.dart';
import 'package:ut_worx/resources/firebase_auth_method.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';
import 'package:ut_worx/view/auth/login_screen.dart';

class CustomDrawerWithNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isPermanent;

  const CustomDrawerWithNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isPermanent = false,
  });

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
          mobile: 200.0,
          tablet: 240.0,
          desktop: 260.0,
        );

        if (isPermanent) {
          return SizedBox(
            width: drawerWidth,
            child: _buildDrawerContent(context, logoHeight, iconSize, fontSize),
          );
        }

        return SizedBox(
          width: drawerWidth,
          child: Drawer(
            backgroundColor: Colors.white,
            child: _buildDrawerContent(context, logoHeight, iconSize, fontSize),
          ),
        );
      },
    );
  }

  Widget _buildDrawerContent(BuildContext context, double logoHeight,
      double iconSize, double fontSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            height: logoHeight + 40,
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            margin: EdgeInsets.zero,
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
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  Icons.dashboard,
                  "Dashboard",
                  index: 0,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
                _drawerItem(
                  Icons.create_outlined,
                  "Notification",
                  index: 1,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
                _drawerItem(
                  Icons.description_outlined,
                  "Preliminary Report",
                  index: 2,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
                _drawerItem(
                  Icons.calendar_today_outlined,
                  "Work Scheduling",
                  index: 3,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
                _drawerItem(
                  Icons.insert_chart_outlined_outlined,
                  "Service Report",
                  index: 4,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
                _drawerItem(
                  Icons.task_outlined,
                  "Report Generation",
                  index: 5,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
                _drawerItem(
                  Icons.inventory_outlined,
                  "My Task",
                  index: 6,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
                _drawerItem(
                  Icons.alarm,
                  "PM Scheduler",
                  index: 7,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
                _drawerItem(
                  Icons.person_add_alt,
                  "Create New User",
                  index: 8,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  context: context,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: const Color(0XFFA3AED0),
              size: iconSize,
            ),
            title: Text(
              "Logout",
              style: TextStyle(
                fontSize: fontSize,
                color: const Color(0XFFA3AED0),
              ),
            ),
            onTap: () async {
              await FirebaseAuthMethods().signOut();
              Navigator.pushAndRemoveUntil(
                // ignore: use_build_context_synchronously
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
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title, {
    required int index,
    required BuildContext context,
    double? iconSize,
    double? fontSize,
  }) {
    final bool isSelected = selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0XFF7DBD2C) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0XFFA3AED0),
          size: iconSize,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            color: isSelected ? Colors.white : const Color(0XFFA3AED0),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          onItemSelected(index);
          if (!isPermanent) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
