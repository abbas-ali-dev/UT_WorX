import 'package:flutter/material.dart';
import 'package:ut_worx/utils/custom_widgets/custom_drawer_with_navigation.dart';
import 'package:ut_worx/utils/custom_widgets/custom_header.dart'; // Import CustomHeader
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';
import 'package:ut_worx/view/auth/signup_screen.dart';
import 'package:ut_worx/view/dashboard/dashboard_screen.dart';
import 'package:ut_worx/view/my_task/my_task.dart';
import 'package:ut_worx/view/notification_creation/notification_screen.dart';
import 'package:ut_worx/view/pms/pms_screen.dart';
import 'package:ut_worx/view/preliminary_report/preliminary_report_screen.dart';
import 'package:ut_worx/view/report_generation/report_generation_screen.dart';
import 'package:ut_worx/view/service_report/service_report_screen.dart';
import 'package:ut_worx/view/work_scheduling/work_scheduling_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      // Reset search query when changing screens
      _searchQuery = '';
    });
  }

  // Handle search query updates
  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, responsive) {
        final bool usePermanentDrawer = !responsive.isMobile;

        // Define header height based on device size
        final headerHeight = responsive.deviceValue(
          mobile: 50.0,
          tablet: 70.0,
          desktop: 80.0,
        );

        return Scaffold(
          backgroundColor: const Color(0XFFF4F7FE),
          drawer: usePermanentDrawer
              ? null
              : CustomDrawerWithNavigation(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemSelected,
                ),
          // No AppBar here
          body: Row(
            children: [
              if (usePermanentDrawer)
                CustomDrawerWithNavigation(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemSelected,
                  isPermanent: true,
                ),
              Expanded(
                child: Column(
                  children: [
                    // CustomHeader inside the body with search callback
                    SizedBox(
                      height: headerHeight,
                      child: CustomHeader(
                        onSearch: _handleSearch,
                      ),
                    ),

                    // Screen content in an Expanded widget
                    Expanded(
                      child: _getScreenWithSearch(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // This method returns the appropriate screen with search functionality
  Widget _getScreenWithSearch() {
    switch (_selectedIndex) {
      case 1: // NotificationListScreen index
        return NotificationListScreen(searchQuery: _searchQuery);
      // Add cases for other screens if they need search functionality
      default:
        // For screens without search functionality, return the original screen
        return _getScreen(_selectedIndex);
    }
  }

  Widget _getScreen(int index) {
    final List<Widget> screens = [
      const DashboardScreen(),
      const NotificationListScreen(),
      const PreliminaryReportScreen(),
      const WorkSchedulingScreen(),
      const ServiceReportScreen(),
      const ReportGeneratorScreen(),
      const MyTaskScreen(),
      const PMSScreen(),
      const SignupScreen(),
    ];

    return screens[index];
  }
}
