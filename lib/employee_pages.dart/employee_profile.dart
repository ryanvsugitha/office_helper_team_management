import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/splash_screen.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EmployeeProfile extends StatefulWidget {
  const EmployeeProfile({super.key});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfile();
}

class _EmployeeProfile extends State<EmployeeProfile> {

  late SharedPreferences pref;

  Future getProfile() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/emp_get_profile.php');
    var request = await http.post(url, body: { 
      'id': pref.getString('id'),
    });
    return request.body;
  }

  Future setLogOut() async {
    pref = await SharedPreferences.getInstance();
    await pref.setBool('status', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/profile.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ], 
      ),
      body: FutureBuilder(
        future: getProfile(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data) as List;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Center(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width * 0.65,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: CachedNetworkImage(
                            imageUrl: 'http://10.0.2.2/OHTM/profile_image/${result[0]['employee_image']}',
                            progressIndicatorBuilder: (context, url, progress) => Center(
                              child: CircularProgressIndicator(value: progress.progress),
                            ),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover
                                )
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        result[0]['employee_id'],
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        result[0]['employee_name'],
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        'Joined on ${result[0]['date_joined']}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Color(0xff9D9D9D)
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: (){
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Are you sure to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: (){
                                    setLogOut();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SplashScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Log Out')
                    ),
                  ),
                ],
              ),
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
                  Text('Loading data...'),
                ],
              ),
            );
          }
        },
      )
    );
  }
}