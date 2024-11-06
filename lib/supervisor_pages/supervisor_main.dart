import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_home.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_office_helper.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_profile.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_report.dart';

class AdminMain extends StatefulWidget{
  const AdminMain({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AdminMain();
  }
}

class _AdminMain extends State<AdminMain>{
  int _selectedNavbar = 0;

  void _changeSelectedNavBar(int index) {
    setState(() {
      _selectedNavbar = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List widgetOptions = [
      const AdminHome(),
      const SupervisorOfficeHelperList(),
      const SupervisorReport(),
      const SupervisorProfile(),
    ];

    return Scaffold(
      body: widgetOptions.elementAt(_selectedNavbar),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Office Helper',
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
          ),
          BottomNavigationBarItem(
            label: 'Report',
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
          ),
        ],
        currentIndex: _selectedNavbar,
        onTap: _changeSelectedNavBar,
      ),
    );
  }
}