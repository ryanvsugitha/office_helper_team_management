import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pencatatan_kinerja_ob/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Office Helper Team Management',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.black
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.black
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff2296F3),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xffF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          elevation: 5.0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true
        ),
        iconTheme: const IconThemeData(
          color: Color(0xff45A4F0)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
            )
          )
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: false,
        primaryColor: const Color(0xff2296F3)
      ),
      home: const SplashScreen(),
    );
  }
}