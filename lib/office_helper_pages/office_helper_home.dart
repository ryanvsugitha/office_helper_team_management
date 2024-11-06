import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_create_add_task.dart';
import 'package:pencatatan_kinerja_ob/report/create_report.dart';
import 'package:pencatatan_kinerja_ob/room_info/room_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OfficeBoyHome extends StatefulWidget {
  const OfficeBoyHome({super.key});

  @override
  State<OfficeBoyHome> createState() => _OfficeBoyHome();
}

class _OfficeBoyHome extends State<OfficeBoyHome> {

  late SharedPreferences pref;
  late String _timeString;
  String name = '';

  @override
  void initState() {
    super.initState();
    getData();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  Future getData() async {
    pref = await SharedPreferences.getInstance();
    final String? id = pref.getString('id');
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_detail.php');
    var request = await http.post(url, body: { 
      "id": id,
    });
    Map result = jsonDecode(request.body) as Map;
    setState(() {
      name = result['oh_name'];
    });
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
          children: [
            Column(
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
            const SizedBox(
              height: 40.0,
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
                        builder: (context) => const RoomInformation(),
                      ),
                    ).then((value){
                      setState(() {
                        
                      });
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.meeting_room_rounded,
                        size: MediaQuery.of(context).size.width * 0.4 * 2/3
                      ),
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
                        builder: (context) => const OfficeHelperCreateAdditionalTask(),
                      ),
                    ).then((value){
                      setState(() {
                        
                      });
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.clean_hands_rounded,
                        size: MediaQuery.of(context).size.width * 0.4 * 2/3
                      ),
                      const Text(
                        'Submit Additional Task',
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        builder: (context) => const CreateReport(),
                      ),
                    ).then((value){
                      setState(() {
                        
                      });
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_rounded,
                        size: MediaQuery.of(context).size.width * 0.4 * 2/3
                      ),
                      const Text(
                        'Create Report',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}