import 'package:flutter/material.dart';
import 'package:ecotrack/screens/home_page.dart';
import 'package:ecotrack/screens/login_screen.dart';
import 'package:ecotrack/screens/signup_screen.dart';
import 'package:ecotrack/screens/splash_screen.dart';
import 'package:ecotrack/screens/user_list_screen.dart';
import 'package:ecotrack/screens/sustainable_shopping_screen.dart';
import 'package:ecotrack/screens/carbon_footprint_screen.dart';
import 'database/app_database.dart';

void main() {
  final db = AppDatabase();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        "/signup": (context) => SignUpScreen(database: db),
        "/login": (context) => LoginScreen(database: db),
        "/home": (context) => HomePage(database: db),
        "/userList": (context) => UserListScreen(database: db),
        "/sustainableShopping": (context) => SustainableShoppingScreen(),
        "/carbonFootprint": (context) => CarbonFootprintScreen(),
      },
    ),
  );
}
