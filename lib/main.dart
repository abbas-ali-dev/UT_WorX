import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ut_worx/constant/easy_loading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ut_worx/view/home_page.dart';
import 'package:ut_worx/view/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCmmkFNGuS7ZqDA1etir4p9_VYgwjKVdJc",
        appId: "1:944090769862:android:200da50987046e298f2ac7",
        messagingSenderId: "944090769862",
        projectId: "ut-works-15d61",
        storageBucket: "ut-works-15d61.firebasestorage.app"),
  );
  await Easyloding.configLoading();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UT WorX',
      builder: EasyLoading.init(),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('Not connected to the stream or null');
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            case ConnectionState.active:
              if (snapshot.hasData) {
                return HomePage();
              } else {
                return OnboardingScreen();
              }
            case ConnectionState.done:
              return const Text('Stream has finished');
          }
        },
      ),
    );
  }
}
