import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OHScheduleUpcoming extends StatefulWidget {
  const OHScheduleUpcoming({super.key, required this.date, required this.startTime});

  final String date;
  final String startTime;

  @override
  State<OHScheduleUpcoming> createState() => _OHScheduleUpcoming();
}

class _OHScheduleUpcoming extends State<OHScheduleUpcoming> {

  late SharedPreferences pref;

  Future getScheduleDetail() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_schedule_detail.php');
    var request = await http.post(url, body: {
      'oh_id': pref.getString('id'),
      'date' : widget.date,
      'start_time' : widget.startTime,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Task Detail'),
      ),
      body: FutureBuilder(
        future: getScheduleDetail(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data) as List;
            return ListView(
              children: [
                Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.50,
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10.0),
                      dashPattern: const [10, 4],
                      strokeWidth: 2.0,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_outlined),
                            Text('Upcoming Task')
                          ],
                        ),
                      )
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.calendar_month_rounded, 
                  title: 'Shift', 
                  content: Text('${result[0]['date']}\n${result[0]['start_time']} - ${result[0]['end_time']}')
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                const Detail(
                  leading: Icons.location_on_rounded,
                  title: 'Room',
                  content: Text('Upcoming Task'),
                  warning: true,
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.clean_hands_rounded,
                  title: 'Task Detail',
                  content: Text(result[0]['task_detail'])
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                const Detail(
                  leading: Icons.chat_rounded, 
                  title: "Office Helper's Remarks", 
                  content: Text('Upcoming Task'),
                  warning: true,
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                const Detail(
                  leading: Icons.star_outline_rounded, 
                  title: "Supervisor's Ratings", 
                  content: Text('Upcoming Task'),
                  warning: true
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                const Detail(
                  leading: Icons.chat_rounded, 
                  title: "Supervisor's Remarks", 
                  content: Text('Upcoming Task'),
                  warning: true
                )
              ],
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text('Loading data...')
                ],
              ),
            );
          }
        },
      )
    );
  }
}