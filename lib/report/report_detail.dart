import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportDetail extends StatefulWidget {
  const ReportDetail({super.key, required this.reportID});

  final String reportID;

  @override
  State<ReportDetail> createState() => _ReportDetail();
}

class _ReportDetail extends State<ReportDetail> {

  late SharedPreferences pref;

  Future getReportDetail() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/get_report_detail.php');
    var request = await http.post(url, body: {
      'report_id': widget.reportID,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Detail'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/report_history.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: getReportDetail(), 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
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
          } else {
            if (snapshot.hasError){
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              List result = jsonDecode(snapshot.data) as List;
              return ListView(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                children: [
                  Center(
                      child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewSingleImage(address: 'http://10.0.2.2/OHTM/report_file/${result[0]['report_file']}'),
                        ),
                      );
                    },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.65,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: CachedNetworkImage(
                          imageUrl: 'http://10.0.2.2/OHTM/report_file/${result[0]['report_file']}',
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
                    title: 'Report Date',
                    content: Text(result[0]['report_time'])
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Colors.white,
                  ),
                  Detail(
                    leading: Icons.location_on_rounded,
                    title: 'Room',
                    content: Text('${result[0]['report_room_id']} - ${result[0]['room_name']}')
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Colors.white,
                  ),
                  Detail(
                    leading: Icons.person_rounded,
                    title: 'Requester',
                    content: Text(
                      (result[0]['employee_name'] == null)
                      ? '${result[0]['reporter_id']} - ${result[0]['oh_name']}'
                      : '${result[0]['reporter_id']} - ${result[0]['employee_name']}',
                    )
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Colors.white,
                  ),
                  Detail(
                    leading: Icons.chat_rounded,
                    title: 'Report Date',
                    content: Text(result[0]['report_remarks'])
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}