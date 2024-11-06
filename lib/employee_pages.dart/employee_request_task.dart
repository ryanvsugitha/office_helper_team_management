import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_create_task.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_request_detail.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EmployeeRequestTask extends StatefulWidget {
  const EmployeeRequestTask({super.key});

  @override
  State<EmployeeRequestTask> createState() => _EmployeeRequestTask();
}

class _EmployeeRequestTask extends State<EmployeeRequestTask> {

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();  

  late SharedPreferences pref;

  String start = '';
  String end = '';
  String selectedRoom= '';

  Future getRoomList() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_all.php');
    var request = await http.post(url, body: {
    });
    return request.body;
  }

  Future getAddTask() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/emp_get_add_task.php');
    var request = await http.post(url, body: {
      'id': pref.getString('id'),
      'selected_room': selectedRoom,
      'start_date': start,
      'end_date': end,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request History'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return FutureBuilder(
                    future: getRoomList(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        List roomList = jsonDecode(snapshot.data) as List;
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
                  builder: (context) => const EMPCreateTask(),
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
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/create_request.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: getAddTask(),
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
                  padding: const EdgeInsets.all(4.0),
                  itemCount: result.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EMPRequestDetail(requestID: result[index]['request_id'])
                            )
                          ).then((value){
                            setState(() {
                              
                            });
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
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
                                width: 8.0,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.info_rounded),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text(result[index]['request_id']),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month_rounded),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text(result[index]['request_made_date']),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_filled_rounded),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text('${result[index]['start_time']} - ${result[index]['end_time']}'),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_rounded),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        Expanded(
                                          child: Text('${result[index]['room_id']} - ${result[index]['room_name']}'),
                                        )
                                      ],
                                    ),
                                    const Divider(),
                                    const Text(
                                      'Request Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        color: (result[index]['status_name'] == 'Rejected')
                                        ? Colors.red
                                        : (result[index]['status_name'] == 'Approved')
                                          ? Colors.green.shade400
                                          : Colors.grey.shade300
                                      ),
                                      child: Text(result[index]['status_name']),
                                    ),
                                    const Text(
                                      'Task Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        color: (result[index]['status'] == 'Done')
                                        ? Colors.green.shade400
                                        : Colors.grey.shade400
                                      ),
                                      child: Text(
                                        result[index]['status'],
                                        // style: TextStyle(
                                        //   color: (result[index]['status'] == 'Done')
                                        //   ? Colors.white
                                        //   : Colors.black
                                        // ),
                                      ),
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