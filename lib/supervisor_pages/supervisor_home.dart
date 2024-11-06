import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pencatatan_kinerja_ob/room_info/room_info.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/spv_oh_list.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminHome extends StatefulWidget{
  const AdminHome({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AdminHome();
  }
}

class _AdminHome extends State<AdminHome>{

  late SharedPreferences pref;
  late String _timeString;
  String name = '';
  bool notif = false;
  int notifCount = 0;

  Future getRequest() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/spv_request_notif.php');
    var request = await http.post(url, body: { 
      'sv_id' : pref.getString('id'),
    });
    List result = jsonDecode(request.body) as List;
    setState(() {
      notifCount = result.length;
      if(notifCount == 0){
        notif = false;
      } else {
        notif = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    getRequest();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  getData() async {
    pref = await SharedPreferences.getInstance();
    final String? id = pref.getString('id');
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_profile.php');
    var request = await http.post(url, body: { 
      "id": id,
    });
    List result = jsonDecode(request.body) as List;
    // String fullName = result[0]['supervisor_name'];
    // List firstName = fullName.split(' ');
    // setState(() {
    //   name = firstName[0];
    // });
    setState(() {
      name = result[0]['supervisor_name'];
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 16.0,
              ),
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
                height: 30.0,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),
                            backgroundColor: const Color(0xff2296F3),
                            fixedSize: const Size(150, 150),
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
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.meeting_room_rounded,
                              size: 100.0),
                              Text('Room Information'),
                            ],
                          )
                        ),
                        const SizedBox(
                          width: 30.0,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),backgroundColor: const Color(0xff2296F3),
                            fixedSize: const Size(150, 150),
                            elevation: 7.0,
                          ),
                          onPressed: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const SPVOHList(),
                              ),
                            ).then((value){
                              setState(() {
                                
                              });
                            });
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.groups,
                              size: 100.0),
                              Text(
                                'Office Helper Detail',
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
                        Badge(
                          isLabelVisible: notif,
                          largeSize: 25,
                          textStyle: const TextStyle(
                            fontSize: 20,
                          ),
                          label: Text('$notifCount'),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              ),
                              backgroundColor: const Color(0xff2296F3),
                              fixedSize: const Size(150, 150),
                              elevation: 7.0,
                            ),
                            onPressed: (){
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => const SPVRequest(),
                                ),
                              ).then((value){
                                setState(() {
                                  
                                });
                              });
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_square,
                                  size: 100.0
                                ),
                                Text('Request'),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}