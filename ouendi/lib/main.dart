import 'package:flutter/material.dart';
import 'package:ouendi/screens/home.dart';
import 'package:ouendi/screens/phone.dart';
import 'package:ouendi/screens/pincode.dart';
import 'package:ouendi/app/helpers/inactivity_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  final user = prefs.getString('user');
  final token = prefs.getString('token');
  final phone = prefs.getString('phone');

  Widget startScreen;

  if (user != null && token != null && phone != null) {
    startScreen = Home();
  } else if (phone != null && (user == null || token == null)) {
    startScreen = PinCode();
  } else {
    startScreen = Phone();
  }

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    bool enableTimer = !(startScreen is Phone || startScreen is PinCode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InactivityScope(
        enable: enableTimer,
        child: startScreen,
      ),
    );
  }
}