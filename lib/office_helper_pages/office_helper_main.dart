import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_home.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_profile.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_schedule.dart';
import 'package:pencatatan_kinerja_ob/report/report_list.dart';

class OfficeBoyMain extends StatefulWidget{
  const OfficeBoyMain({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OfficeBoyMain();
  }
}

class _OfficeBoyMain extends State<OfficeBoyMain>{
  int _selectedNavbar = 0;

  void _changeSelectedNavBar(int index) {
    setState(() {
      _selectedNavbar = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List widgetOptions = [
      const OfficeBoyHome(),
      const OfficeHelperSchedule(),
      const ReportList(),
      const Profile(),
    ];

    return Scaffold(
      body: widgetOptions.elementAt(_selectedNavbar),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            tooltip: 'Home Menu',
          ),
          BottomNavigationBarItem(
            label: 'Daily Task',
            icon: Icon(Icons.clean_hands_outlined),
            activeIcon: Icon(Icons.clean_hands),
            tooltip: 'Daily Schedule',
          ),
          BottomNavigationBarItem(
            label: 'Report',
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            tooltip: 'Report List',
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            tooltip: 'Profile Information',
          ),
        ],
        currentIndex: _selectedNavbar,
        onTap: _changeSelectedNavBar,
      ),
    );
  }
}