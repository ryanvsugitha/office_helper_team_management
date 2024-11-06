import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OHScheduleDetail extends StatefulWidget {
  const OHScheduleDetail({super.key, required this.date, required this.startTime});

  final String date;
  final String startTime;

  @override
  State<OHScheduleDetail> createState() => _OHScheduleDetail();
}

class _OHScheduleDetail extends State<OHScheduleDetail> {

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
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/oh_daily_task.pdf'),)
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
                      padding: const EdgeInsets.all(8.0), 
                      height: MediaQuery.of(context).size.width * 0.45,
                      width: MediaQuery.of(context).size.width * 0.35,
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
                            title: "Office Helper's Status",
                            content: Container(
                              padding: const EdgeInsets.only(right: 4.0, left: 4.0, top: 2.0, bottom: 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: (result[0]['oh_status'] == 'Late')
                                ? Colors.red.shade400
                                : Colors.green.shade300
                              ),
                              child: Text(
                                (result[0]['oh_status'] == 'Late')
                                ? '${result[0]['oh_status']}\n${result[0]['reason_name']}\n${result[0]['report_date']}'
                                : '${result[0]['oh_status']}\n${result[0]['report_date']}',
                                style: const TextStyle(
                                  color: Colors.black
                                ),
                              ),
                            )
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
                              padding: const EdgeInsets.only(right: 4.0, left: 4.0, top: 2.0, bottom: 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: (result[0]['sv_status'] == 'Need Rate')
                                ? Colors.amber
                                : Colors.green.shade300
                              ),
                              child: Text(
                                (result[0]['sv_status'] == 'Need Rate')
                                ? result[0]['sv_status']
                                : '${result[0]['sv_status']}\n${result[0]['sv_date']}'
                              )
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
                    Detail(
                      leading: Icons.chat_rounded,
                      title: "Office Helper's Remarks",
                      content: Text(result[0]['oh_remarks'])
                    ),
                    const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    ),
                    Detail(
                      leading: Icons.star_rounded,
                      title: "Supervisor's Rating",
                      content: (result[0]['sv_rating'] == null)
                      ? const Text('Need Response from Supervisor')
                      : RatingBarIndicator(
                        rating: double.parse(result[0]['sv_rating']),
                        itemBuilder: (context, index) {
                          return const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          );
                        },
                        itemSize: 25.0,
                      ),
                      warning: (result[0]['sv_rating'] == null)
                      ? true
                      : false,
                    ),
                    const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    ),
                    Detail(
                      leading: Icons.chat_rounded,
                      title: "Supervisor's Review",
                      content: (result[0]['sv_remarks'] == null)
                      ? const Text('Need Response from Supervisor')
                      : Text(result[0]['sv_remarks']),
                      warning: (result[0]['sv_remarks'] == null)
                      ? true
                      : false,
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