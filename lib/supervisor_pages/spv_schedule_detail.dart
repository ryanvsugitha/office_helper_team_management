import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class SPVScheduleDetail extends StatefulWidget {
  const SPVScheduleDetail({super.key, required this.officeHelperID, required this.date, required this.startTime});

  final String officeHelperID;
  final String date;
  final String startTime;

  @override
  State<SPVScheduleDetail> createState() => _SPVScheduleDetail();
}

class _SPVScheduleDetail extends State<SPVScheduleDetail> {

  int rating = 0;
  bool warningRating = false;
  bool warningRemarks = false;
  TextEditingController remarks = TextEditingController();

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
                      padding: const EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.width * 0.40,
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: (result[0]['report_file'] != null)
                      ? InkWell(
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
                      : DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10.0),
                        dashPattern: const [10, 4],
                        strokeWidth: 2.0,
                        color: Colors.red,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                color: Colors.red,
                              ),
                              Text(
                                'No image',
                                style: TextStyle(
                                  color: Colors.red
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xffF5F5F5),
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
                              : (result[0]['oh_status'] == 'Late/Not Submitted')
                                ? Container(
                                  padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.red.shade400
                                  ),
                                  child: Text('${result[0]['oh_status']}')
                                )
                                : (result[0]['oh_status'] == 'Upcoming')
                                  ? Container(
                                    padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.grey.shade400
                                    ),
                                    child: Text('${result[0]['oh_status']}')
                                  )
                                  : (result[0]['oh_status'] == 'Ongoing')
                                    ? Container(
                                      padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        color: Colors.amber
                                      ),
                                      child: Text('${result[0]['oh_status']}')
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
                              content: (result[0]['sv_status'] == 'Rated')
                              ? Container(
                                padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.green.shade400
                                ),
                                child: Text(result[0]['sv_status'])
                              )
                              : Container(
                                padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.grey.shade400
                                ),
                                child: Text(result[0]['sv_status'])
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    ),
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
                      content: (result[0]['room_id'] == null)
                      ? const Text('Not submitted')
                      : Text('${result[0]['room_id']} - ${result[0]['room_name']}'),
                      warning: (result[0]['room_id'] == null)
                      ? true
                      : false,
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
                      content: (result[0]['oh_remarks'] == null)
                      ? const Text('Not submitted')
                      : Text('${result[0]['oh_remarks']}'),
                      warning: (result[0]['oh_remarks'] == null)
                      ? true
                      : false,
                    ),
                    const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    ),
                    Detail(
                      leading: Icons.star_rounded, 
                      title: "Supervisor's Rating", 
                      content: (result[0]['sv_status'] != 'Rated')
                      ? const Text('Not submitted')
                      : RatingBarIndicator(
                        rating: double.parse(result[0]['sv_rating']),
                        itemBuilder: (context, index) {
                          return const Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                          );
                        },
                      ),
                      warning: (result[0]['sv_status'] != 'Rated')
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
                      ? const Text('Not submitted')
                      : Text('${result[0]['sv_remarks']}'),
                      warning: (result[0]['sv_remarks'] == null)
                      ? true
                      : false,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
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
                  Text('Loading Data...'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}