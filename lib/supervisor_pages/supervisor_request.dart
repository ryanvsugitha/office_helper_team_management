import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_request_detail.dart';
import 'package:pencatatan_kinerja_ob/supervisor_pages/supervisor_request_response.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SPVRequest extends StatefulWidget {
  const SPVRequest({super.key});

  @override
  State<SPVRequest> createState() => _SPVRequest();
}

class _SPVRequest extends State<SPVRequest> {

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();  

  String start = '';
  String end = '';
  String selectedRoom = '';
  String orderBy = 'DESC';
  String status = 'All';

  late SharedPreferences pref;

  Future getRequest() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/spv_get_request.php');
    var request = await http.post(url, body: { 
      'sv_id': pref.getString('id'),
      'start_date': start,
      'end_date': end,
      'order_by': orderBy,
      'room_id': selectedRoom,
      'status': status,
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

  Future getReqStatus() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/req_get_status.php');
    var request = await http.post(url, body: {
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
          'Request List',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return FutureBuilder(
                    future: Future.wait([getRoomList(), getReqStatus()]),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        List roomList = jsonDecode(snapshot.data![0]) as List;
                        List statusList = jsonDecode(snapshot.data![1]) as List;
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
                                        label: const Text('Sort by Request Made Date'),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'DESC',
                                          child: Text('Descending'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'ASC',
                                          child: Text('Ascending'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        innerSetState(() {
                                          orderBy = value.toString();
                                        },);
                                      },
                                      value: orderBy,
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
                                        label: const Text('Status'),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'All',
                                          child: Text('All'),
                                        ),
                                        for(int i=0; i<statusList.length; i++)
                                        DropdownMenuItem(
                                          value: statusList[i]['status_id'].toString(),
                                          child: Text(statusList[i]['status_name']),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        innerSetState(() {
                                          status = value.toString();
                                        },);
                                      },
                                      value: status,
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
                                            status = 'All';
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
            icon: const Icon(Icons.filter_alt_rounded)
          ),
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
        future: getRequest(),
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
                child: Text('${snapshot.error}'),
              );
            } else {
              List result = jsonDecode(snapshot.data) as List;
              if(result.isEmpty){
                return const Center(
                  child: Text('No Data'),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(4.0),
                  itemCount: result.length,
                  itemBuilder: (context, index) {
                    return Card(
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
                              builder: (context) => (result[index]['status_name'] == 'Waiting')
                              ? SPVRequestResponse(requestID: result[index]['request_id'],)
                              : SPVRequestDetail(requestID: result[index]['request_id'],),
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
                                ),
                              ),
                              const SizedBox(
                                width: 8.0,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.info_rounded),
                                        const SizedBox(
                                          width: 4.0,
                                        ),
                                        Expanded(
                                          child: Text(result[index]['request_id']),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_rounded),
                                        const SizedBox(
                                          width: 4.0,
                                        ),
                                        Expanded(
                                          child: Text(result[index]['requester_id']),
                                        )
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.edit_calendar_rounded),
                                        const SizedBox(
                                          width: 4.0,
                                        ),
                                        Expanded(
                                          child: Text(result[index]['request_made_date']),
                                        )
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.help_rounded),
                                        const SizedBox(
                                          width: 4.0,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            color: (result[index]['status_name'] == 'Waiting')
                                            ? Colors.amber.shade300
                                            : (result[index]['status_name'] == 'Rejected')
                                              ? Colors.red.shade300
                                              : Colors.green.shade300
                                          ),
                                          child: Text(result[index]['status_name'])
                                        )
                                      ],
                                    ),
                                  ],
                                ),
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
      ),
    );
  }
}