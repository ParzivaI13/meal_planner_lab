import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:ui'; 
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'package:provider/provider.dart'; 
import 'state/meal_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

 await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MealPlannerApp());
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MealState(),
      child: MaterialApp(
        title: 'Meal Planner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF28a745),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF28a745),
            primary: const Color(0xFF28a745),
          ),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        home: const AuthGate(),
      ),
    );
  }
}