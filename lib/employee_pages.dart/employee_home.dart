import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pencatatan_kinerja_ob/all/qr_scanner.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_create_task.dart';
import 'package:pencatatan_kinerja_ob/room_info/room_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});

  @override
  State<EmployeeHome> createState() => _EmployeeHome();
}

class _EmployeeHome extends State<EmployeeHome> {

  late SharedPreferences pref;
  String name = '';
  late String _timeString;

  Future getData() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/emp_get_profile.php');
    var request = await http.post(url, body: { 
      "id": pref.getString('id'),
    });
    List result = jsonDecode(request.body) as List;
    setState(() {
      name = result[0]['employee_name'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, d/M/y, hh:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Welcome, ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff45A4F0)
                          )
                        ),
                        TextSpan(
                          text: name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          )
                        )
                      ]
                    )
                  ),
                  Text(
                    _timeString,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade700,
                      // fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(MediaQuery.of(context).size.width * 0.4, MediaQuery.of(context).size.width * 0.4),
                        elevation: 7.0,
                      ),
                      onPressed: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const RoomInformation(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_rounded,
                          size: MediaQuery.of(context).size.width * 0.4 * 2/3),
                          const Text(
                            'Room Information',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    ),
                    const SizedBox(
                      width: 30.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(MediaQuery.of(context).size.width * 0.4, MediaQuery.of(context).size.width * 0.4),
                        elevation: 7.0,
                      ),
                      onPressed: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            // builder: (context) => const RoomScanner(),
                            builder: (context) => const QRScanner(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_chart_rounded,
                            size: MediaQuery.of(context).size.width * 0.4 * 2/3
                          ),
                          const Text(
                            'Rate a Room',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(MediaQuery.of(context).size.width * 0.4, MediaQuery.of(context).size.width * 0.4),
                        elevation: 7.0,
                      ),
                      onPressed: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const EMPCreateTask(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.clean_hands_rounded,
                          size: MediaQuery.of(context).size.width * 0.4 * 2/3),
                          const Text(
                            'Request Task',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}