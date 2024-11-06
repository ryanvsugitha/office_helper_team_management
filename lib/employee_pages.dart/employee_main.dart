import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_home.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_profile.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_request_task.dart';
import 'package:pencatatan_kinerja_ob/report/report_list.dart';

class EmployeeMain extends StatefulWidget {
  const EmployeeMain({super.key});

  @override
  State<EmployeeMain> createState() => _EmployeeMain();
}

class _EmployeeMain extends State<EmployeeMain> {
  int _selectedNavbar = 0;

  void _changeSelectedNavBar(int index) {
    setState(() {
      _selectedNavbar = index;
    });
  }

  final List widgetOptions = [
    const EmployeeHome(),
    const EmployeeRequestTask(),
    const ReportList(),
    const EmployeeProfile(),
  ];
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: widgetOptions.elementAt(_selectedNavbar),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            tooltip: 'Main Menu'
          ),
          BottomNavigationBarItem(
            label: 'Request',
            icon: Icon(Icons.clean_hands_outlined),
            activeIcon: Icon(Icons.clean_hands_rounded),
            tooltip: 'Request History'
          ),
          BottomNavigationBarItem(
            label: 'Report',
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat_rounded),
            tooltip: 'Report History'
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            tooltip: 'Profile Information'
          ),
        ],
        currentIndex: _selectedNavbar,
        onTap: _changeSelectedNavBar,
      ),
    );
  }
}