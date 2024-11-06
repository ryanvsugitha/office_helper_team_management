import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class SPVRequestDetail extends StatefulWidget {
  const SPVRequestDetail({super.key, required this.requestID});

  final String requestID;

  @override
  State<SPVRequestDetail> createState() => _SPVRequestDetail();
}

class _SPVRequestDetail extends State<SPVRequestDetail> {

  Future getRequestDetail() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/spv_get_request_detail.php');
    var request = await http.post(url, body: {
      'request_id' : widget.requestID,
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
        title: const Text(
          'Request Detail',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/request_response.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: getRequestDetail(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data) as List;
            return ListView(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.width * 0.40,
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewSingleImage(address: 'http://10.0.2.2/OHTM/add_task_file/${result[0]['report_file']}'),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: 'http://10.0.2.2/OHTM/add_task_file/${result[0]['report_file']}',
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
                    Expanded(
                      child: Column(
                        children: [
                          Detail(
                            leading: Icons.info_rounded, 
                            title: 'Request ID', 
                            content: Text(result[0]['request_id'])
                          ), 
                          const Divider(
                            height: 4,
                            thickness: 4,
                            color: Colors.white,
                          ),
                          Detail(
                            leading: Icons.help_rounded, 
                            title: 'Request Status', 
                            content: Container(
                              padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: (result[0]['status_name'] == 'Waiting')
                                ? Colors.amber.shade300
                                : (result[0]['status_name'] == 'Rejected')
                                  ? Colors.red.shade300
                                  : Colors.green.shade300
                              ),
                              child: Text('${result[0]['status_name']} by ${result[0]['sv_approver']}\n${result[0]['approval_time']}')
                            )
                          ),
                        ],
                      )
                    )
                  ],
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.person_rounded, 
                  title: 'Requester ID', 
                  content: Text('${result[0]['requester_id']} - ${result[0]['employee_name']}')
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.edit_calendar_rounded, 
                  title: 'Request Made Date', 
                  content: Text(result[0]['request_made_date'])
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.access_time_filled_rounded, 
                  title: 'Request Time and Date', 
                  content: Text('${result[0]['request_date']}\n${result[0]['start_time']} - ${result[0]['end_time']}')
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.location_on_rounded, 
                  title: 'Room', 
                  content: Text('${result[0]['room_id']} - ${result[0]['room_name']}')
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