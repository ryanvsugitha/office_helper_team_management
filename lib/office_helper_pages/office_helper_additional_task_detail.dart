import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class OHAddTaskDetail extends StatefulWidget {
  const OHAddTaskDetail({super.key, required this.reqID});

  final String reqID;

  @override
  State<OHAddTaskDetail> createState() => _OHAddTaskDetail();
}

class _OHAddTaskDetail extends State<OHAddTaskDetail> {

  Future getAddTaskDetail() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_add_task_detail.php');
    var request = await http.post(url, body: {
      'req_id': widget.reqID,
    });
    return request.body;
  }

  Future getAssignedOH() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/get_asg_oh_add_task_detail.php');
    var request = await http.post(url, body: {
      'req_id': widget.reqID,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Task Detail'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/oh_add_task.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([getAddTaskDetail(), getAssignedOH()]), 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data![0]) as List;
            List assignedOH = jsonDecode(snapshot.data![1]) as List;
            return ListView(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0), 
                      height: MediaQuery.of(context).size.width * 0.45,
                      width: MediaQuery.of(context).size.width * 0.35,
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
                      )
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Detail(
                            leading: Icons.info_rounded, 
                            title: 'Request Status', 
                            content: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: (result[0]['status'] == 'Done')
                                  ? Colors.green.shade400
                                  : (result[0]['status'] == 'Not Submitted')
                                    ? Colors.amber.shade400
                                    : Colors.grey.shade400
                              ),
                              padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                              child: Text(
                                (result[0]['status'] == 'Done')
                                ? '${result[0]['status']}\n${result[0]['submit_time']}'
                                : result[0]['status'],
                              ),
                            ),
                          )
                        ],
                      )
                    ),
                  ],
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
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
                  leading: Icons.person_rounded, 
                  title: 'Requester', 
                  content: Text(
                    (result[0]['supervisor_name'] != null)
                    ? '${result[0]['supervisor_id']} - ${result[0]['supervisor_name']}'
                    : (result[0]['employee_name'] != null)
                      ? '${result[0]['employee_id']} - ${result[0]['employee_name']}'
                      : 'Self Submitted',
                  )
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.groups_rounded, 
                  title: 'Assigned Office Helper', 
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for(int i=0; i<assignedOH.length; i++)
                      Text('${assignedOH[i]['oh_id']} - ${assignedOH[i]['oh_name']}')
                    ],
                  ),
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.calendar_month_rounded, 
                  title: 'Request Made Date', 
                  content: Text(result[0]['request_made_date']),
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.access_time_filled_rounded, 
                  title: 'Request Time and Date', 
                  content: Text('${result[0]['request_date']}\n${result[0]['start_time']} - ${result[0]['end_time']}'),
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.location_on_rounded, 
                  title: 'Request Locaton', 
                  content: Text('${result[0]['room_id']} - ${result[0]['room_name']}'),
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.clean_hands_rounded, 
                  title: 'Task Detail', 
                  content: Text(result[0]['task_detail']),
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.chat_rounded, 
                  title: "Office Helper's Remarks", 
                  content: Text(
                    (result[0]['oh_remarks'] == null)
                    ? 'Not Submitted'
                    : '${result[0]['oh_remarks']}\nRemarks by ${result[0]['oh_submitter']}',
                  ),
                  warning: (result[0]['oh_remarks'] == null)
                  ? true
                  : false,
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
      ),
    );
  }
}