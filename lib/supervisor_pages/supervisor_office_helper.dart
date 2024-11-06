import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/spv_schedule.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SupervisorOfficeHelperList extends StatefulWidget {
  const SupervisorOfficeHelperList({super.key});

  @override
  State<SupervisorOfficeHelperList> createState() => _SupervisorOfficeHelperList();
}

class _SupervisorOfficeHelperList extends State<SupervisorOfficeHelperList> {

  late SharedPreferences pref;

  Future getOfficeHelperList() async {
    pref = await SharedPreferences.getInstance();
    final String? id = pref.getString('id');
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_ob.php');
    var request = await http.post(url, body: { 
      "id": id,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(
        color: Colors.black
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.black
        ),
        title: const Text(
          'Office Helper List',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/spv_oh_task.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: getOfficeHelperList(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data) as List;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: result.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupervisorSchedule(officeHelperID: result[index]['oh_id']),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.center,
                          colors: [Color(0xff8DCDFF), Color(0xff67B4F1),Color(0xff45A4F0)],
                        ),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.20,
                            height: MediaQuery.of(context).size.width * 0.25,
                            child: CachedNetworkImage(
                              imageUrl: 'http://10.0.2.2/OHTM/profile_image/${result[index]['oh_image']}',
                              progressIndicatorBuilder: (context, url, progress) => Center(
                                child: CircularProgressIndicator(value: progress.progress),
                              ),
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    width: 1,
                                    color: Colors.white
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: imageProvider,
                                  )
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result[index]['oh_name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),  
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  result[index]['oh_id'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Loading data...')
                ],
              ),
            );
          }
        },
      ),
    );
  }
}