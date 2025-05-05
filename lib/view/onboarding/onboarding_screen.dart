// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ut_worx/constant/enums.dart';
import 'package:ut_worx/utils/custom_widgets/method_channel.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';
import 'package:ut_worx/view/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Selected user level
  String? selectedUserLevel;

  // Track which item is being hovered
  int? hoveredIndex;

  // Track if dropdown is open
  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF4F7FE),
      body: Stack(
        children: [
          Positioned(
            top: 0.0,
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.fill,
            ),
          ),
          ResponsiveLayout(
            builder: (context, responsive) {
              // Get responsive values based on device type
              final containerWidth = responsive.deviceValue(
                mobile: 350.0,
                tablet: 400.0,
                desktop: 500.0,
              );

              final padding = responsive.deviceValue(
                mobile: 15.0,
                tablet: 25.0,
                desktop: 25.0,
              );

              final titleFontSize = responsive.deviceValue(
                mobile: 18.0,
                tablet: 22.0,
                desktop: 24.0,
              );

              final buttonPadding = responsive.deviceValue(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              );

              final logoHeight = responsive.deviceValue(
                mobile: 80.0,
                tablet: 100.0,
                desktop: 120.0,
              );

              return Center(
                child: Container(
                  width: containerWidth,
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: logoHeight,
                      ),
                      SizedBox(height: 20),

                      // Welcome text
                      Text(
                        "Welcome to UTWorX",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      Text(
                        "Please select your user level to continue",
                        style: TextStyle(
                          fontSize: responsive.deviceValue(
                            mobile: 14.0,
                            tablet: 16.0,
                            desktop: 18.0,
                          ),
                          color: Color(0XFF667085),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),

                      // Custom dropdown with hover effects
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0XFFE4E7EC)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isDropdownOpen = !isDropdownOpen;
                            });
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 45,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedUserLevel ?? "Select User Level",
                                      style: TextStyle(
                                        color: selectedUserLevel == null
                                            ? Color(0XFF667085)
                                            : Colors.black,
                                      ),
                                    ),
                                    Icon(
                                      isDropdownOpen
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: Color(0XFF667085),
                                    ),
                                  ],
                                ),
                              ),
                              if (isDropdownOpen)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    children: List.generate(
                                      UserLevel.values.length,
                                      (index) => MouseRegion(
                                        onEnter: (_) {
                                          setState(() {
                                            hoveredIndex = index;
                                          });
                                        },
                                        onExit: (_) {
                                          setState(() {
                                            hoveredIndex = null;
                                          });
                                        },
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedUserLevel = UserLevel
                                                  .values
                                                  .elementAt(index)
                                                  .toString()
                                                  .split('.')[1];
                                              debugPrint(
                                                  'Selected User Level: $selectedUserLevel');
                                              isDropdownOpen = false;
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 8,
                                            ),
                                            color: hoveredIndex == index
                                                ? Color(0XFF7DBD2C)
                                                    .withOpacity(0.1)
                                                : Colors.transparent,
                                            child: Text(
                                              UserLevel.values
                                                  .elementAt(index)
                                                  .toString()
                                                  .split('.')[1],
                                              style: TextStyle(
                                                color: hoveredIndex == index
                                                    ? Color(0XFF7DBD2C)
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Continue button with hover effect
                      MouseRegion(
                        cursor: selectedUserLevel == null
                            ? SystemMouseCursors.forbidden
                            : SystemMouseCursors.click,
                        child: SizedBox(
                          height: responsive.deviceValue(
                            mobile: 45.0,
                            tablet: 45.0,
                            desktop: 45.0,
                          ),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Color(0XFF7DBD2C).withOpacity(0.5);
                                  }
                                  if (states.contains(WidgetState.hovered)) {
                                    return Color(0XFF7DBD2C).withOpacity(0.8);
                                  }
                                  return Color(0XFF7DBD2C);
                                },
                              ),
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(vertical: buttonPadding),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: selectedUserLevel == null
                                ? NativeBridge.getNativeMessage
                                : () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                          settings: RouteSettings(
                                              name: selectedUserLevel)),
                                    );
                                  },
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: responsive.deviceValue(
                                  mobile: 14.0,
                                  tablet: 16.0,
                                  desktop: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
