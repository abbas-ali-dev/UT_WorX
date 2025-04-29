import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ut_worx/screen_models/user_model.dart';
import 'package:ut_worx/resources/firebase_database.dart';
import 'package:ut_worx/utils/resposive_design/responsive_layout.dart';

class CustomHeader extends StatefulWidget {
  // Add a callback function to handle search
  final Function(String)? onSearch;

  const CustomHeader({super.key, this.onSearch});

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  // Add a text controller for the search bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listener to detect changes in search text
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // This function will be called whenever the text changes
  void _onSearchChanged() {
    if (widget.onSearch != null) {
      widget.onSearch!(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    return ResponsiveLayout(
      builder: (context, responsive) {
        // Define responsive values for AppBar
        final searchBarHeight = responsive.deviceValue(
          mobile: 25.0,
          tablet: 28.0,
          desktop: 30.0,
        );

        final iconSize = responsive.deviceValue(
          mobile: 20.0,
          tablet: 22.0,
          desktop: 25.0,
        );

        final avatarRadius = responsive.deviceValue(
          mobile: 14.0,
          tablet: 15.0,
          desktop: 16.0,
        );

        final userNameFontSize = responsive.deviceValue(
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
        );

        final appBarPadding = responsive.deviceValue(
          mobile: 6.0,
          tablet: 10.0,
          desktop: 14.0,
        );

        // Hide username on small screens
        final showUsername = !responsive.isMobile;

        return Padding(
          padding: EdgeInsets.all(appBarPadding),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: SizedBox(
              height: searchBarHeight,
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: SearchBar(
                controller: _searchController, // Add the controller here
                elevation: WidgetStateProperty.all(0),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: const Color(0XFFE4E7EC), width: 1),
                )),
                leading: Icon(Icons.search,
                    color: Color(0XFF667085), size: iconSize * 0.8),
                backgroundColor:
                    WidgetStateProperty.all(const Color(0XFFF9FAFB)),
                hintText: 'Search or type command...',
                hintStyle: WidgetStateProperty.all(TextStyle(
                  color: Color(0XFF667085),
                  fontSize: responsive.deviceValue(
                    mobile: 12.0,
                    tablet: 13.0,
                    desktop: 14.0,
                  ),
                )),
                padding: WidgetStateProperty.all(EdgeInsets.only(left: 10)),
                onSubmitted: (value) {
                  // Handle search submission
                  if (widget.onSearch != null) {
                    widget.onSearch!(value);
                  }
                },
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.circle_notifications_outlined,
                  color: Color(0XFF667085),
                  size: iconSize,
                ),
                onPressed: () {},
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: responsive.deviceValue(
                    mobile: 8.0,
                    tablet: 12.0,
                    desktop: 16.0,
                  ),
                  left: responsive.deviceValue(
                    mobile: 4.0,
                    tablet: 8.0,
                    desktop: 12.0,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          const AssetImage('assets/images/profile.png'),
                      radius: avatarRadius,
                    ),
                    if (showUsername) ...[
                      SizedBox(
                          width: responsive.deviceValue(
                        mobile: 6.0,
                        tablet: 8.0,
                        desktop: 10.0,
                      )),
                      // StreamBuilder for user name

                      FutureBuilder<UserModel?>(
                        future: FirebaseDatabase().getUserDetails(userId),
                        builder: (context, snapshot) {
                          final String displayName =
                              snapshot.data?.email ?? "User";
                          return Text(
                            displayName,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: userNameFontSize,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
