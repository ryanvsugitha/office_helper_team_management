import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_additional_task_detail.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_create_add_task.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_schedule_detail.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_schedule_input.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_schedule_upcoming.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/oh_add_task_response.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OfficeHelperSchedule extends StatefulWidget{
  const OfficeHelperSchedule({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OfficeHelperSchedule();
  }
}

class _OfficeHelperSchedule extends State<OfficeHelperSchedule>{
  int selectedIndex = 0;
  String ohID = '';

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  late SharedPreferences pref;

  Future getSchedule() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_schedule.php');
    var request = await http.post(url, body: {
      'oh_id': pref.getString('id'),
      'start_date' : "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'end_date' : "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    });
    await Future.delayed(const Duration(seconds: 1));
    return request.body;
  }

  Future getAdditionalTask() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_add_task.php');
    var request = await http.post(url, body: {
      'oh_id': pref.getString('id'),
      'start_date' : "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'end_date' : "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    });
    await Future.delayed(const Duration(seconds: 1));
    return request.body;
  }

  getOHID() async {
    pref = await SharedPreferences.getInstance();
    ohID = pref.getString('id')!;
  }

  @override
  void initState() {
    super.initState();
    getOHID();
    getSchedule();
    startDateController.text = "${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}";
    endDateController.text = "${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Task'),
          automaticallyImplyLeading: false,
          actions: [
            if(selectedIndex == 1) 
              IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OfficeHelperCreateAdditionalTask(),)
                  ).then((value){
                    setState(() {
                      
                    });
                  });
                },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  (selectedIndex == 1) 
                  ? MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/oh_add_task.pdf'),)
                  : MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/oh_daily_task.pdf'),)
                ).then((value){
                  setState(() {
                    
                  });
                });
              }, 
              icon: const Icon(Icons.question_mark_rounded)
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        label: const Text('Start Date'),
                        suffixIcon: const Icon(Icons.calendar_month_rounded),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(DateTime.now().year+1),  
                        );
                        if (picked != null && picked != startDate) {
                          setState(() {
                            startDate = picked;
                            startDateController.text = "${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}";
                          });
                        }
                      },
                    )
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                    child: TextField(
                      controller: endDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        label: const Text('End Date'),
                        suffixIcon: const Icon(Icons.calendar_month_rounded),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(DateTime.now().year+1),  
                        );
                        if (picked != null && picked != endDate) {
                          setState(() {
                            endDate = picked;
                            endDateController.text = "${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}";
                          });
                        }
                      },
                    )
                  ),
                ],
              ),
            ),
            TabBar(   
              onTap: (value){
                setState(() {
                  selectedIndex = value;
                });
              },
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  child: Text(
                    'Daily Task',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Additional Task',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ]
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  FutureBuilder(
                    future: getSchedule(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        List result = jsonDecode(snapshot.data) as List;
                        if(result.isEmpty){
                          return const Center(
                            child: Text('No Data Found'),
                          );
                        } else {
                          return ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: result.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 5.0,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: () {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (context) {
                                          if(result[index]['status'] == 'Ongoing' || result[index]['status'] == 'Late/Not Submitted'){
                                            return OHScheduleInput(date: result[index]['date'], startTime: result[index]['start_time']);
                                          } else if(result[index]['status'] == 'Upcoming'){
                                            return OHScheduleUpcoming(date: result[index]['date'], startTime: result[index]['start_time']);
                                          } else {
                                            return OHScheduleDetail(date: result[index]['date'], startTime: result[index]['start_time']);
                                          }
                                        },
                                      )
                                    ).then((value){
                                      setState(() {});
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: MediaQuery.of(context).size.width * 0.30,
                                              width: MediaQuery.of(context).size.width * 0.20,
                                              child: (result[index]['report_file'] != null)
                                              ? CachedNetworkImage(
                                                  imageUrl: 'http://10.0.2.2/OHTM/task_file/${result[index]['report_file']}',
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
                                            const SizedBox(
                                              width: 10.0,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.calendar_month_rounded),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        '${result[index]['day_name']}, ${result[index]['date']}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.access_time_filled_rounded),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        '${result[index]['start_time']} - ${result[index]['end_time']}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.clean_hands_rounded),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Expanded(
                                                        child: Text(result[index]['task_detail']),
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(),
                                                  const Text("Office Helper's Status"),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      color: (result[index]['status'] == 'Done')
                                                        ? Colors.green.shade400
                                                        : (result[index]['status'] == 'Upcoming')
                                                          ? Colors.grey.shade400
                                                          : (result[index]['status'] == 'Ongoing')
                                                            ? Colors.amber.shade400
                                                            : Colors.red.shade400,
                                                    ),
                                                    padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                                    child: Text(result[index]['status']),
                                                  ),
                                                  const Text("Supervisor's Status"),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      color: (result[index]['sv_status'] == 'Rated')
                                                        ? Colors.green.shade400
                                                        : (result[index]['sv_status'] == 'Need Rate')
                                                          ? Colors.amber.shade400
                                                          : Colors.grey.shade400
                                                    ),
                                                    padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                                    child: Text(result[index]['sv_status']),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
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
                  FutureBuilder(
                    future: getAdditionalTask(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        List result = jsonDecode(snapshot.data) as List;
                        if(result.isEmpty){
                          return const Center(
                            child: Text('No data found'),
                          ); 
                        } else {
                          return ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: result.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 5.0,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        if(result[index]['status'] == 'Done' || result[index]['status'] == 'Upcoming'){
                                          return OHAddTaskDetail(reqID: result[index]['request_id']);
                                        } else {
                                          return OHAddTaskResponse(reqID: result[index]['request_id']);
                                        }
                                      },)
                                    ).then((value){
                                      setState(() {
                                        
                                      });
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context).size.width * 0.30,
                                          width: MediaQuery.of(context).size.width * 0.20,
                                          child: (result[index]['report_file'] != null)
                                          ? CachedNetworkImage(
                                              imageUrl: 'http://10.0.2.2/OHTM/add_task_file/${result[index]['report_file']}',
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
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.calendar_month_rounded),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    result[index]['request_date'],
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.location_on_rounded),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text('${result[index]['room_id']} - ${result[index]['room_name']}'),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.clean_hands_rounded),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      result[index]['task_detail'],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    children: [
                                                      const Text('Task Status'),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          color: (result[index]['status'] == 'Done')
                                                            ? Colors.green.shade400
                                                            : (result[index]['status'] == 'Not Submitted')
                                                              ? Colors.amber.shade400
                                                              : Colors.grey.shade400
                                                        ),
                                                        padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                                        child: Text(result[index]['status']),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
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
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}