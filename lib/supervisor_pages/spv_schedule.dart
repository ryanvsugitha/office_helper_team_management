import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/spv_create_add_task.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/spv_schedule_response.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_add_task_detail.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/spv_schedule_detail.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class SupervisorSchedule extends StatefulWidget {
  const SupervisorSchedule({super.key, required this.officeHelperID});

  final String officeHelperID;

  @override
  State<SupervisorSchedule> createState() => _SupervisorSchedule();
}

class _SupervisorSchedule extends State<SupervisorSchedule> {

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  int selectedIndex = 0;

  Future getSchedule() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_schedule.php');
    var request = await http.post(url, body: {
      'oh_id': widget.officeHelperID,
      'start_date' : "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'end_date' : "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    });
    return request.body;
  }

  Future getAdditionalTask() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/sv_get_add_task.php');
    var request = await http.post(url, body: {
      'oh_id': widget.officeHelperID,
      'start_date' : "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'end_date' : "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    });
    return request.body;
  }

  Future getOHDetail() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/oh_get_profile.php');
    var request = await http.post(url, body: {
      'id': widget.officeHelperID,
    });
    return request.body;
  }

  @override
  void initState() {
    super.initState();
    startDateController.text = "${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}";
    endDateController.text = "${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
          color: Colors.black
          ),
          actionsIconTheme: const IconThemeData(
            color: Colors.black
          ),
          backgroundColor: Colors.white,
          title: Text(
            widget.officeHelperID,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          actions: [
            IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  (selectedIndex == 0)
                  ? MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/spv_oh_response.pdf'),)
                  : MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/request_response.pdf'),)
                );
              }, 
              icon: const Icon(Icons.question_mark_rounded)
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SPVCreateAddTask(ohID: widget.officeHelperID,),)
                );
              }, 
              icon: const Icon(Icons.add)
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.center,
                  colors: [Color(0xff8DCDFF), Color(0xff67B4F1),Color(0xff45A4F0)],
                ),
              ),
              child: Column(
                children: [
                  FutureBuilder(
                    future: getOHDetail(), 
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        List ohInfo = jsonDecode(snapshot.data) as List;
                        return Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.20,
                              height: MediaQuery.of(context).size.width * 0.25,
                              child: CachedNetworkImage(
                                imageUrl: 'http://10.0.2.2/OHTM/profile_image/${ohInfo[0]['oh_image']}',
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
                              height: 5.0,
                            ),
                            Text(
                              ohInfo[0]['oh_name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),  
                            ),
                            Text(
                              ohInfo[0]['oh_id'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        );
                      } else {
                        return SizedBox(
                          height: MediaQuery.of(context).size.width * 0.25,
                          child: Center(
                            child: LoadingAnimationWidget.waveDots(
                              color: Colors.black,
                              size: 20
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.white
                                )
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              labelStyle: const TextStyle(
                                color: Colors.white
                              ),
                              label: const Text('Start Date'),
                              suffixIcon: const Icon(
                                Icons.calendar_month_rounded,
                                color:  Colors.white,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white
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
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              label: const Text('End Date'),
                              suffixIcon: const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              labelStyle: const TextStyle(
                                color: Colors.white
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white
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
                ],
              ),
            ),
            TabBar(
              onTap: (value){
                setState(() {
                  selectedIndex = value;
                });
              },
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
                ),
              ]
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FutureBuilder(
                    future: getSchedule(), 
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        List result = jsonDecode(snapshot.data) as List;
                        if(result.isEmpty){
                          return const Center(
                            child: Text(
                              'No Data Found',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          );
                        } else {
                          return Scrollbar(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: result.length,
                              itemBuilder: (context, index) {
                                if (result[index]['task_detail'] == 'OFF'){
                                  return Card(
                                    color: const Color(0xffF5F5F5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    elevation: 5.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.calendar_month_rounded,
                                                color: Color(0xff45A4F0),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${result[index]['day_name']}, ${result[index]['date']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.access_time_filled_rounded,
                                                color: Color(0xff45A4F0),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${result[index]['start_time']} - ${result[index]['end_time']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.clean_hands_rounded,
                                                color: Color(0xff45A4F0),
                                              ),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                child: Text('OFF')
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Card(
                                    elevation: 5.0,
                                    color: const Color(0xffF5F5F5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10.0),
                                      onTap: () {
                                        Navigator.push(
                                          context, 
                                          MaterialPageRoute(
                                            builder: (context) => (result[index]['sv_status'] == 'Need Rate')
                                            ? SPVScheduleResponse(
                                              officeHelperID: widget.officeHelperID,
                                              date: result[index]['date'],
                                              startTime: result[index]['start_time'],
                                            )
                                            : SPVScheduleDetail(
                                              officeHelperID: widget.officeHelperID,
                                              date: result[index]['date'],
                                              startTime: result[index]['start_time'],
                                            ),
                                          )
                                        ).then((value) {
                                          setState(() {
                                            
                                          });
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: MediaQuery.of(context).size.width * 0.3,
                                              width: MediaQuery.of(context).size.width * 0.2,
                                              child: (result[index]['report_file'] != null)
                                              ? CachedNetworkImage(
                                                imageUrl: 'http://10.0.2.2/OHTM/task_file/${result[index]['report_file']}',
                                                progressIndicatorBuilder: (context, url, progress) => Center(
                                                  child: CircularProgressIndicator(value: progress.progress)
                                                ),
                                                imageBuilder: (context, imageProvider) => Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: imageProvider
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
                                                      const Icon(
                                                        Icons.calendar_month_rounded,
                                                        color: Color(0xff45A4F0),
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '${result[index]['day_name']}, ${result[index]['date']}',
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.access_time_filled_rounded,
                                                        color: Color(0xff45A4F0),
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '${result[index]['start_time']} - ${result[index]['end_time']}',
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.clean_hands_rounded,
                                                        color: Color(0xff45A4F0),
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Expanded(
                                                        child: Text(result[index]['task_detail'])
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
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }
                      } else {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text('Loading data...')
                          ],
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
                            child: Text('No Data Found'),
                          );
                        } else {
                          return ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: result.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SupervisorAddTaskDetail(reqID: result[index]['request_id']),)
                                  ).then((value){
                                    setState(() {
                                      
                                    });
                                  });
                                },
                                child: Card(
                                  color: const Color(0xffF5F5F5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  elevation: 5.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context).size.width * 0.30,
                                          width: MediaQuery.of(context).size.width * 0.20,
                                          child: CachedNetworkImage(
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
                                                  const Icon(
                                                    Icons.calendar_month_rounded,
                                                    color: Color(0xff45A4F0),
                                                  ),
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
                                                  const Icon(
                                                    Icons.access_time_filled_rounded,
                                                    color: Color(0xff45A4F0),
                                                  ),
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
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.clean_hands_rounded,
                                                    color: Color(0xff45A4F0),
                                                  ),
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
                                                              : (result[index]['status'] == 'Overdue')
                                                                ? Colors.red.shade400
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
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text('Loading data...'),
                          ],
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