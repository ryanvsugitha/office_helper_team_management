import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SupervisorReportDetail extends StatefulWidget {
  const SupervisorReportDetail({super.key, required this.reportID});

  final String reportID;

  @override
  State<SupervisorReportDetail> createState() => _SupervisorReportDetail();
}

class _SupervisorReportDetail extends State<SupervisorReportDetail> {

  late SharedPreferences pref;

  Future getReportDetail() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_report_detail.php');
    var request = await http.post(url, body: { 
      'report_id': widget.reportID,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
        color: Colors.black
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Report Detail',
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
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/spv_report.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: getReportDetail(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
          List result = jsonDecode(snapshot.data);
            return ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              children: [
                Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.50,
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewSingleImage(address: 'http://10.0.2.2/OHTM/report_file/${result[0]['report_file']}'),)
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: 'http://10.0.2.2/OHTM/report_file/${result[0]['report_file']}',
                        progressIndicatorBuilder: (context, url, progress) => Center(
                          child: CircularProgressIndicator(value: progress.progress),
                        ),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: imageProvider
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Detail(
                  leading: Icons.info_rounded, 
                  title: 'Report ID', 
                  content: Text(result[0]['report_id'])
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.calendar_month_rounded, 
                  title: 'Report Date and Time', 
                  content: Text(result[0]['report_time'])
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.person_search_rounded, 
                  title: 'Reporter ID', 
                  content: Text(result[0]['reporter_id'])
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.manage_search_rounded, 
                  title: 'Report Type', 
                  content: Text(result[0]['report_type_name'])
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.location_on_rounded, 
                  title: 'Report Room', 
                  content: Text('${result[0]['room_id']} - ${result[0]['room_name']}')
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.chat_rounded, 
                  title: "Reporter's Remarks", 
                  content: Text(result[0]['report_remarks'])
                ),
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
      ),
    );
  }
}