import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/spv_schedule_detail.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class SPVScheduleResponse extends StatefulWidget {
  const SPVScheduleResponse({super.key, required this.officeHelperID, required this.date, required this.startTime});

  final String officeHelperID;
  final String date;
  final String startTime;

  @override
  State<SPVScheduleResponse> createState() => _SPVScheduleResponse();
}

class _SPVScheduleResponse extends State<SPVScheduleResponse> {

  final _formKey = GlobalKey<FormState>(); 

  int rating = 0;
  bool ratingWarning = false;
  TextEditingController remarks = TextEditingController();
  final alphanumeric = RegExp(r'^[a-zA-Z0-9.,/]+$');

  Future submit() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_submit_rating.php');
    var request = await http.post(url, body: {
      'oh_id': widget.officeHelperID,
      'date' : widget.date,
      'start_time' : widget.startTime,
      'rating' : rating.toString(),
      'remarks': remarks.text,
    });
    return request.body;
  }

  Future getScheduleDetail() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_schedule_detail.php');
    var request = await http.post(url, body: {
      'oh_id': widget.officeHelperID,
      'date' : widget.date,
      'start_time' : widget.startTime,
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
          'Schedule Detail',
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
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/spv_oh_response.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: getScheduleDetail(), 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data) as List;
            return ListView(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      height: MediaQuery.of(context).size.width * 0.40,
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewSingleImage(address: 'http://10.0.2.2/OHTM/task_file/${result[0]['report_file']}'),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: 'http://10.0.2.2/OHTM/task_file/${result[0]['report_file']}',
                          progressIndicatorBuilder: (context, url, progress) => Center(child: CircularProgressIndicator(value: progress.progress)),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover
                              )
                            ),
                          ),
                        )
                      )
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Detail(
                            leading: Icons.info_rounded, 
                            title: "Office Helper's Status", 
                            content: (result[0]['oh_status'] == 'Late')
                            ? Container(
                              padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.red.shade400
                              ),
                              child: Text('${result[0]['oh_status']}\n${result[0]['reason_name']}\n${result[0]['report_date']}')
                            )
                            : Container(
                              padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.green.shade400
                              ),
                              child: Text('${result[0]['oh_status']}\n${result[0]['report_date']}')
                            ),
                          ),
                          const Divider(
                            height: 4,
                            thickness: 4,
                            color: Colors.white,
                          ),
                          Detail(
                            leading: Icons.info_rounded, 
                            title: "Supervisor's Status", 
                            content: Container(
                              padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.grey.shade400
                              ),
                              child: Text(result[0]['sv_status'])
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Column(
                  children: [
                    Detail(
                      leading: Icons.calendar_month_rounded, 
                      title: 'Shift Detail', 
                      content: Text('${result[0]['date']}\n${result[0]['start_time']} - ${result[0]['end_time']}')
                    ),
                    const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    ),
                    Detail(
                      leading: Icons.location_on_rounded, 
                      title: 'Location', 
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
                      content: Text('${result[0]['task_detail']}')
                    ),
                    const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    ),
                    Detail(
                      leading: Icons.chat_rounded, 
                      title: "Office Helper's Remarks", 
                      content: Text('${result[0]['oh_remarks']}')
                    ),
                    const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    ),
                    Detail(
                      leading: Icons.star_rounded, 
                      title: "Supervisor's Rating", 
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBar.builder(
                            glow: false,
                            minRating: 1,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,  
                              );
                            }, 
                            onRatingUpdate: (value) {
                              setState(() {
                                rating = value.toInt();
                              });
                            },
                          ),
                          (ratingWarning == true)
                          ? const Text(
                            'Please input rating',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12
                            ),
                          )
                          : Container(),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    ),
                    Detail(
                      leading: Icons.chat_rounded, 
                      title: "Supervisor's Review", 
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: remarks,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Kerja bagus, Jangan terlambat lagi'
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            } else {
                              String check = value.replaceAll(' ', '');
                              if(check == ''){
                                return 'Please enter some text';
                              } else if(!alphanumeric.hasMatch(check)){
                                return 'Please input only alphanumeric';
                              } else {
                                return null;
                              }
                            }
                          },
                        ),
                      )
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: 
                      ElevatedButton(
                        onPressed: (){
                          if(rating == 0){
                            setState(() {
                              ratingWarning = true;
                            });
                          } else {
                            setState(() {
                              ratingWarning = false;
                            });
                          }
                          if(_formKey.currentState!.validate() && rating != 0){
                            submit().then((value){
                              Map result = jsonDecode(value) as Map;
                              showDialog(
                                barrierDismissible: false,
                                context: context, 
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(result['title']),
                                    actions: [
                                      TextButton(
                                        onPressed: (){
                                          if(result['result'] == '1'){
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => SPVScheduleDetail(officeHelperID: widget.officeHelperID, date: widget.date, startTime: widget.startTime),)
                                            );
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        }, 
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            });
                          }
                        }, 
                        child: const Text('Submit')
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
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