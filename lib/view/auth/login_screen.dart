// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ut_worx/constant/toaster.dart';
import 'package:ut_worx/screen_models/user_model.dart';
import 'package:ut_worx/resources/firebase_auth_method.dart';
import 'package:ut_worx/resources/firebase_database.dart';
import 'package:ut_worx/view/home_page.dart';
import '../../utils/resposive_design/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Function to handle login attempt
  Future<void> _attemptLogin() async {
    EasyLoading.show();
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _showError = true;
      });
      EasyLoading.dismiss();
      return;
    }
    if (!_emailController.text.isEmail) {
      setState(() {
        _showError = true;
      });
      EasyLoading.dismiss();
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _showError = true;
      });
      EasyLoading.dismiss();
      return;
    }
    try {
      final authMethods = FirebaseAuthMethods();

      User? firebaseUser = await authMethods.loginInUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if widget is still mounted before using context or setState
      if (!mounted) {
        EasyLoading.dismiss();
        return;
      }

      if (firebaseUser != null) {
        UserModel? userModel =
            await FirebaseDatabase().getUserDetails(firebaseUser.uid);

        // Check again if widget is still mounted
        if (!mounted) {
          EasyLoading.dismiss();
          return;
        }

        EasyLoading.dismiss();
        Toaster.showToast('Login successful');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
          (route) => false,
        );
      } else {
        // Check if widget is still mounted before using setState
        if (!mounted) {
          EasyLoading.dismiss();
          return;
        }

        setState(() {
          _showError = true;
        });
        EasyLoading.dismiss();
        Toaster.showToast('Login failed: Invalid credentials');
      }
    } catch (e) {
      debugPrint("Error during login process: $e");

      // Check if widget is still mounted
      if (!mounted) {
        EasyLoading.dismiss();
        return;
      }

      EasyLoading.dismiss();
      Toaster.showToast('An error occurred: ${e.toString()}');

      setState(() {
        _showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userRole = ModalRoute.of(context)?.settings.name ?? '';

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

              final labelFontSize = responsive.deviceValue(
                mobile: 14.0,
                tablet: 15.0,
                desktop: 16.0,
              );

              final buttonPadding = responsive.deviceValue(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              );

              final logoHeight = responsive.deviceValue(
                mobile: 60.0,
                tablet: 70.0,
                desktop: 80.0,
              );

              return Center(
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                        Image.asset(
                          'assets/images/logo.png',
                          height: logoHeight,
                        ),
                        SizedBox(
                            height: responsive.deviceValue(
                          mobile: 8.0,
                          desktop: 15.0,
                        )),
                        Text(
                          "Login in to UTWorX",
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                            height: responsive.deviceValue(
                          mobile: 15.0,
                          desktop: 25.0,
                        )),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: labelFontSize,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          autofillHints: [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          cursorColor: Color(0XFF7DBD2C),
                          decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0XFF7DBD2C),
                              ),
                            ),
                            hintText: "Please enter email",
                            hintStyle: TextStyle(
                              color: Color(0XFF737373),
                              // fontSize: responsive.deviceValue(
                              //   mobile: 10.0,
                              //   tablet: 12.0,
                              //   desktop: 14.0,
                              // ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: responsive.deviceValue(
                                mobile: 10.0,
                                desktop: 14.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: responsive.deviceValue(
                          mobile: 12.0,
                          desktop: 20.0,
                        )),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: labelFontSize,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          autofillHints: [AutofillHints.password],
                          controller: _passwordController,
                          obscureText: true,
                          cursorColor: Color(0XFF7DBD2C),
                          decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0XFF7DBD2C),
                              ),
                            ),
                            hintText: "Please enter password",
                            hintStyle: TextStyle(
                              color: Color(0XFF737373),
                              // fontSize: responsive.deviceValue(
                              //   mobile: 10.0,
                              //   tablet: 12.0,
                              //   desktop: 14.0,
                              // ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: responsive.deviceValue(
                                mobile: 10.0,
                                tablet: 12.0,
                                desktop: 14.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: responsive.deviceValue(
                            mobile: 25.0,
                            tablet: 30.0,
                            desktop: 35.0,
                          ),
                        ),
                        SizedBox(
                          height: responsive.deviceValue(
                            mobile: 45.0,
                            tablet: 45.0,
                            desktop: 45.0,
                          ),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0XFF7DBD2C),
                              padding:
                                  EdgeInsets.symmetric(vertical: buttonPadding),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await _attemptLogin();
                            },
                            child: Text(
                              "Login",
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
                        SizedBox(
                            height: responsive.deviceValue(
                          mobile: 10.0,
                          desktop: 14.0,
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                _showForgotPasswordDialog();
                              },
                              child: Text(
                                "Forgot Password",
                                style: TextStyle(
                                  color: Color(0XFF1A71F6),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0XFF1A71F6),
                                  fontSize: responsive.deviceValue(
                                    mobile: 14.0,
                                    desktop: 16.0,
                                  ),
                                ),
                              ),
                            ),
                            // Spacer(),
                            // TextButton(
                            //   onPressed: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => SignupScreen(),
                            //       ),
                            //     );
                            //   },
                            //   child: Text(
                            //     "Sign Up",
                            //     style: TextStyle(
                            //       color: Color(0XFF7DBD2C),
                            //       fontWeight: FontWeight.w600,
                            //       fontFamily: 'Inter',
                            //       decoration: TextDecoration.underline,
                            //       decorationColor: Color(0XFF7DBD2C),
                            //       fontSize: responsive.deviceValue(
                            //         mobile: 14.0,
                            //         desktop: 16.0,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),

                        // Error message box - only shown when _showError is true
                        if (_showError)
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFFFEE2E2),
                              border: Border.all(
                                color: Color.fromARGB(255, 255, 164, 164),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Incorrect login credentials',
                                  style: TextStyle(
                                    color: Color(0xFF991B1B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsive.deviceValue(
                                      mobile: 12.0,
                                      desktop: 14.0,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'The username or password you entered doesn\'t seem to match. Please verify your details and try again.',
                                  style: TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontSize: responsive.deviceValue(
                                      mobile: 10.0,
                                      desktop: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  // Inside your _LoginScreenState class, add this method:

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ResponsiveLayout(
            builder: (context, responsive) {
              final dialogWidth = responsive.deviceValue(
                mobile: 300.0,
                tablet: 350.0,
                desktop: 400.0,
              );

              final logoHeight = responsive.deviceValue(
                mobile: 50.0,
                tablet: 60.0,
                desktop: 70.0,
              );

              final titleFontSize = responsive.deviceValue(
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              );

              final contentFontSize = responsive.deviceValue(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              );

              final buttonPadding = responsive.deviceValue(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              );

              return Container(
                color: Color(0XFFFFFFFF),
                width: dialogWidth,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: logoHeight,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Reset Your Password",
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "It looks like you've requested a password reset. No worries—we've got you covered!\nClick the button below to reset your password and regain access to your account.",
                      style: TextStyle(
                        fontSize: contentFontSize,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: responsive.deviceValue(
                        mobile: 45.0,
                        tablet: 45.0,
                        desktop: 45.0,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0XFF7DBD2C),
                          padding:
                              EdgeInsets.symmetric(vertical: buttonPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Reset Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.deviceValue(
                              mobile: 12.0,
                              tablet: 12.0,
                              desktop: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
