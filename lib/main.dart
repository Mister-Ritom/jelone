import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:jelone/firebase_options.dart';
import 'package:jelone/pages/main_page.dart';
import 'package:jelone/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
      )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      themeMode: themeProvider.themeMode,

      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.purpleAccent,
          backgroundColor: Colors.black12,
          brightness: Brightness.dark,
        ),
        //Appbar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black12,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.black12,
          elevation: 12,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 45, 27, 42),
          elevation: 12,
        ),
        //Text field theme
        inputDecorationTheme: InputDecorationTheme(
          border: InputBorder.none,
          filled: true,

          contentPadding: const EdgeInsets.all(6),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[500]!,
            ),
          ),
          //border radius
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          // label
          labelStyle: TextStyle(
            color: Colors.grey[500],
          ),
          hintStyle: TextStyle(
            color: Colors.grey[400],
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.grey[300],
          ),
        ),
        //Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
            ),
            
          ),
        ),
        cardColor: Colors.black26,
      ),
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.deepPurpleAccent,
          backgroundColor: Colors.grey[200],
        ),
        //Appbar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        //Text field theme
        inputDecorationTheme: InputDecorationTheme(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.all(6),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[500]!,
            ),
          ),
          //border radius
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          // label
          labelStyle: TextStyle(
            color: Colors.grey[700],
          ),
          hintStyle: TextStyle(
            color: Colors.grey[400],
          ),
        ),
        //Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
            ),
            
          ),
        ),
      ),
    );
  }
}