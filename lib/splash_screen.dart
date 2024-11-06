import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_main.dart';
import 'package:pencatatan_kinerja_ob/login.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_main.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {

  late SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  Future getStatus() async {
    pref = await SharedPreferences.getInstance();
    final bool? status = pref.getBool('status');
    final String? role = pref.getString('role');

    if (status == null || status == false){
      await Future.delayed(const Duration(seconds: 1));
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()
        ),
      );
    } else {
      await Future.delayed(const Duration(seconds: 1));
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => 
          (role == '1') ? const AdminMain() : 
          (role == '2') ? const OfficeBoyMain() : const EmployeeMain(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'splash_art',
          child: Image.asset('assets/logo.png')
        ),
      ),
    );
  }
}