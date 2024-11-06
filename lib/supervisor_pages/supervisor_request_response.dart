import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_request_detail.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPVRequestResponse extends StatefulWidget {
  const SPVRequestResponse({super.key, required this.requestID});

  final String requestID;

  @override
  State<SPVRequestResponse> createState() => _SPVRequestResponse();
}

class _SPVRequestResponse extends State<SPVRequestResponse> {

  late SharedPreferences pref;

  List assignedOH = [];
  List valueOH = [];

  Future getRequestDetail() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/spv_get_request_detail.php');
    var request = await http.post(url, body: {
      'request_id' : widget.requestID,
    });
    return request.body;
  }

  Future reject() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/spv_reject_request.php');
    var request = await http.post(url, body: {
      'request_id' : widget.requestID,
      'approver_id' : pref.getString('id'),
    });
    return request.body;
  }

  Future getOH() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/spv_get_oh_request.php');
    var request = await http.post(url, body: {
      'spv_id' : pref.getString('id'),
    });
    return request.body;
  }

  Future approve() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/spv_accept_request.php');
    var request = await http.post(url, body: {
      'request_id' : widget.requestID,
      'spv_id' : pref.getString('id'),
      'assigned_oh': jsonEncode(assignedOH),
      'value_oh': jsonEncode(valueOH)
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
          'Response Request',
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
                      padding: const EdgeInsets.all(4.0), 
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
                            title: 'Request ID', 
                            content: Text(result[0]['request_id'])
                          ),
                          const Divider(
                            height: 4,
                            thickness: 4,
                            color: Colors.white,
                          ),
                          Detail(
                            leading: Icons.help_outlined, 
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
                              child: Text(result[0]['status_name'])
                            )
                          ),
                        ],
                      ), 
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
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                      ),
                      onPressed: (){
                        showDialog(
                          barrierDismissible: false,
                          context: context, 
                          builder: (context) {
                            return AlertDialog(
                              actionsAlignment: MainAxisAlignment.spaceAround,
                              title: const Text('Reject Request'),
                              content: Text('Reject Request ID ${widget.requestID} ?'),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  }, 
                                  child: const Text('Cancel')
                                ),
                                TextButton(
                                  onPressed: (){
                                    reject().then((value){
                                      Navigator.pop(context);
                                      List response = jsonDecode(value) as List;
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            actionsAlignment: MainAxisAlignment.center,
                                            title: Text(response[0]['title']),
                                            content: Text(response[0]['message']),
                                            actions: [
                                              TextButton(
                                                onPressed: (){
                                                  Navigator.pop(context);
                                                  Navigator.pushReplacement(
                                                    context, 
                                                    MaterialPageRoute(builder: (context) => SPVRequestDetail(requestID: widget.requestID))
                                                  );
                                                }, 
                                                child: const Text('OK')
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    });
                                  }, 
                                  child: const Text('Ok')
                                )
                              ],
                            );
                          },
                        );
                      }, 
                      child: const Text('Reject')
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                      ),
                      onPressed: (){
                        showDialog(
                          barrierDismissible: false,
                          context: context, 
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, innerSetState) {
                                return AlertDialog(
                                  actionsAlignment: MainAxisAlignment.spaceAround,
                                  title: const Text('Select Office Helper'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: FutureBuilder(
                                      future: getOH(), 
                                      builder: (context, snapshot) {
                                        if(snapshot.hasData){
                                          List oh = jsonDecode(snapshot.data) as List;
                                          for(int i=0; i<oh.length; i++){
                                            if(!assignedOH.contains(oh[i]['oh_id'])){
                                              assignedOH.add(oh[i]['oh_id']);
                                              valueOH.add(false);
                                            }
                                          }
                                          return ListView.separated(
                                            shrinkWrap: true,
                                            separatorBuilder: (context, index) {
                                              return const Divider(
                                                color: Colors.black,
                                              );
                                            },
                                            itemCount: oh.length,
                                            itemBuilder: (context, index) {
                                              return Row(
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.15,
                                                    height: MediaQuery.of(context).size.width * 0.20,
                                                    child: CachedNetworkImage(
                                                      imageUrl: 'http://10.0.2.2/OHTM/profile_image/${oh[index]['oh_image']}',
                                                      progressIndicatorBuilder: (context, url, progress) => Center(
                                                        child: CircularProgressIndicator(value: progress.progress),
                                                      ),
                                                      imageBuilder: (context, imageProvider) => Container(
                                                        decoration: BoxDecoration(
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
                                                    width: 10.0,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(oh[index]['oh_id']),
                                                        Text(oh[index]['oh_name'])
                                                      ],
                                                    ),
                                                  ),
                                                  Checkbox(
                                                    value: valueOH[index], 
                                                    onChanged: (value) {
                                                      innerSetState(() {
                                                        valueOH[index] = value;
                                                      });
                                                    },
                                                  )
                                                ],
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
                                                  height: 10.0,
                                                ),
                                                Text('Loading data...')
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    )
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: (){
                                        Navigator.pop(context);
                                      }, 
                                      child: const Text('Cancel')
                                    ),
                                    TextButton(
                                      onPressed: (){
                                        approve().then((value){
                                          List result = jsonDecode(value) as List;
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context, 
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(result[0]['title']),
                                                content: Text(result[0]['content']),
                                                actionsAlignment: MainAxisAlignment.spaceAround,
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: (){
                                                        Navigator.pop(context);
                                                        if(result[0]['result'] == 1){
                                                          Navigator.pop(context);
                                                          Navigator.pushReplacement(
                                                            context, 
                                                            MaterialPageRoute(builder: (context) => SPVRequestDetail(requestID: widget.requestID),)
                                                          );
                                                        }
                                                    },
                                                    child: const Text('Ok')
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        });
                                      }, 
                                      child: const Text('Submit')
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }, 
                      child: const Text('Approve')
                    ),
                  ],
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
      )
    );
  }
}