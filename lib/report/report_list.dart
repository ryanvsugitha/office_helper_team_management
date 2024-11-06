import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/report/create_report.dart';
import 'package:pencatatan_kinerja_ob/report/report_detail.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportList();
}

class _ReportList extends State<ReportList> {

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();  

  late SharedPreferences pref;

  String start = '';
  String end = '';
  String selectedReportType = '';
  String selectedRoom= '';

  Future getReport() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/oh_get_report.php');
    var request = await http.post(url, body: {
      'id': pref.getString('id'),
      'start_date': start,
      'end_date': end,
      'report_type': selectedReportType,
      'report_room': selectedRoom,
    });
    return request.body;
  }

  Future getRoomList() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_all.php');
    var request = await http.post(url, body: {
    });
    return request.body;
  }

  Future getReportTypeList() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/report_type_get_all.php');
    var request = await http.post(url, body: {
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report History'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return FutureBuilder(
                    future: Future.wait([getRoomList(), getReportTypeList()]),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        List roomList = jsonDecode(snapshot.data![0]) as List;
                        List reportTypeList = jsonDecode(snapshot.data![1]) as List;
                        return StatefulBuilder(
                          builder: (context, innerSetState) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
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
                                            if (picked != null) {
                                              innerSetState(() {
                                                startDate = picked;
                                                start = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
                                                startDateController.text = "${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}";
                                              },);
                                            }
                                          },
                                        )
                                      ),
                                      const SizedBox(
                                        width: 10.0,
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
                                            if (picked != null) {
                                              innerSetState(() {
                                                endDate = picked;
                                                end = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
                                                endDateController.text = "${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}";
                                              },);
                                            }
                                          },
                                        )
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButtonFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        label: const Text('Report Type'),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          enabled: false,
                                          value: '',
                                          child: Text(
                                            'Select Report Type',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        for(int i=0; i<reportTypeList.length; i++)
                                        DropdownMenuItem(
                                          value: reportTypeList[i]['report_type_id'].toString(),
                                          child: Text(reportTypeList[i]['report_type_name']),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        innerSetState(() {
                                          selectedReportType = value.toString();
                                        },);
                                      },
                                      value: selectedReportType,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButtonFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        label: const Text('Report Room'),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          enabled: false,
                                          value: '',
                                          child: Text(
                                            'Select Report Room',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        for(int i=0; i<roomList.length;i++)
                                        DropdownMenuItem(
                                          value: roomList[i]['room_id'].toString(),
                                          child: Text('${roomList[i]['room_id']} - ${roomList[i]['room_name']}'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        innerSetState(() {
                                          selectedRoom = value.toString();
                                        },);
                                      },
                                      value: selectedRoom,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade400,
                                        ),
                                        onPressed: (){
                                          innerSetState(() {
                                            startDate = DateTime.now();
                                            endDate = DateTime.now();
                                            startDateController.text = '';
                                            endDateController.text = '';
                                            selectedReportType = '';
                                            selectedRoom = '';
                                            start = '';
                                            end = '';
                                          });
                                        },
                                        child: const Text('Reset')
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade400,
                                        ),
                                        onPressed: (){
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: const Text('Filter')
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                  );
                },
              );
            },
            icon: const Icon(Icons.filter_alt_outlined)
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateReport(),
                )
              ).then((value){
                setState(() {
                  
                });
              });
            },
            icon: const Icon(Icons.add)
          ),
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
        future: getReport(),
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
            if(snapshot.hasError){
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetail(reportID: result[index]['report_id'],),
                            )
                          ).then((value){
                            setState(() {
                              
                            });
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.center,
                              colors: [Color(0xff8DCDFF), Color(0xff67B4F1),Color(0xff45A4F0)],
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.width * 0.30,
                                width: MediaQuery.of(context).size.width * 0.20,
                                child: CachedNetworkImage(
                                  imageUrl: 'http://10.0.2.2/OHTM/report_file/${result[index]['report_file']}',
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
                                        image: imageProvider,
                                        fit: BoxFit.cover
                                      )
                                    ),
                                  ),
                                )
                              ),
                              const SizedBox(
                                width: 8.0,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.info_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            result[index]['report_id'],
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                          )
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            result[index]['report_time'],
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                          )
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${result[index]['report_room_id']} - ${result[index]['room_name']}',
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                          )
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            (result[0]['employee_name'] == null)
                                            ? '${result[0]['reporter_id']} - ${result[0]['oh_name']}'
                                            : '${result[0]['reporter_id']} - ${result[0]['employee_name']}',
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                          )
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.chat_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            result[index]['report_remarks'],
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                          )
                                        )
                                      ],
                                    ),
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
            }
          }
        },
      )
    );
  }
}