import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EMPCreateTask extends StatefulWidget {
  const EMPCreateTask({super.key});

  @override
  State<EMPCreateTask> createState() => _EMPCreateTask();
}

class _EMPCreateTask extends State<EMPCreateTask> {

  final _formKey = GlobalKey<FormState>();
  late SharedPreferences pref;
  final alphanumeric = RegExp(r'^[a-zA-Z0-9.,/]+$');

  String imagePath = '';
  bool imageWarning = false;
  String roomID = '';

  TextEditingController taskDetail = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();

  DateTime dateChoosen = DateTime.now();
  TimeOfDay startTimeChoosen = TimeOfDay.now();
  TimeOfDay endTimeChoosen = TimeOfDay.now();

  bool isUploading = false;

  Future getRoomList() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_all.php');
    var request = await http.post(url, body: {
    });
    return request.body;
  }

  Future submit() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/emp_request_help.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['id'] = pref.getString('id')!;
    request.fields['date'] = '${dateChoosen.year}-${dateChoosen.month.toString().padLeft(2, '0')}-${dateChoosen.day.toString().padLeft(2, '0')}';
    request.fields['start_time'] = startTime.text;
    request.fields['end_time'] = endTime.text;
    request.fields['task_detail'] = taskDetail.text;
    request.fields['room_id'] = roomID;
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imagePath,
    ));

    var res = await request.send();
    var body = await http.Response.fromStream(res);
    return body.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Office Helper'),
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: getRoomList(), 
          builder: (context, snapshot) {
            if(snapshot.hasData){
              List roomList = jsonDecode(snapshot.data) as List;
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      (imagePath == '')
                      ? InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () async {
                          final image = await ImagePicker().pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                          );
                          if (image == null) return;
                          setState(() {
                            imagePath = image.path;
                          });
                        },
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10.0),
                          dashPattern: const [10, 4],
                          strokeWidth: 2.0,
                          color: (imageWarning)
                          ? Colors.red
                          : Colors.black,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.40,
                            height: MediaQuery.of(context).size.width * 0.50,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined),
                                  Text('Take a picture'),
                                ],
                              ),
                            ),
                          )
                        ),
                      )
                      : Image.file(
                        File(imagePath),
                        width: MediaQuery.of(context).size.width * 0.40,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: date,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          label: const Text('Date'),
                          prefixIcon: const Icon(Icons.calendar_month_rounded),
                        ),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: dateChoosen,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year+1),  
                          );
                          if (picked != null) {
                            setState(() {
                              dateChoosen = picked;
                              date.text = "${dateChoosen.day.toString().padLeft(2, '0')}/${dateChoosen.month.toString().padLeft(2, '0')}/${dateChoosen.year}";
                            },);
                          }
                        },
                        validator: (value) {
                          if(value == null || value == ''){
                            return 'Please select date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: startTime,
                              onTap: () async {
                                TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now()
                                );
                                if(time != null){
                                  startTimeChoosen = time;
                                  startTime.text = '${startTimeChoosen.hour.toString().padLeft(2, '0')}:${startTimeChoosen.minute.toString().padLeft(2, '0')}:00';
                                }
                              },
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                label: const Text('Start Time'),
                                prefixIcon: const Icon(Icons.access_time)
                              ),
                              validator: (value) {
                                if(value == null || value == ''){
                                  return 'Please select start time';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: endTime,
                              onTap: () async {
                                TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now()
                                );
                                if(time != null){
                                  endTimeChoosen = time;
                                  endTime.text = '${endTimeChoosen.hour.toString().padLeft(2, '0')}:${endTimeChoosen.minute.toString().padLeft(2, '0')}:00';
                                }
                              },
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                label: const Text('End Time'),
                                prefixIcon: const Icon(Icons.access_time)
                              ),
                              validator: (value) {
                                if(value == null || value == ''){
                                  return 'Please select end time';
                                }
                                return null;
                              },
                            ),
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
                            label: const Text('Select Room'),
                          ),
                          items: [
                            const DropdownMenuItem(
                              enabled: false,
                              value: '',
                              child: Text(
                                'Select Room',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            for(int i=0; i<roomList.length; i++)
                            DropdownMenuItem(
                              value: roomList[i]['room_id'],
                              child: Text('${roomList[i]['room_id']} - ${roomList[i]['room_name']}'),
                            )
                          ], 
                          onChanged: (value) {
                            roomID = value.toString();
                          },
                          value: '',
                          validator: (value) {
                          if (value == '') {
                              return 'Please select Room';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: taskDetail,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          label: const Text('Task Detail'),
                          hintText: 'Menyusun denah ruangan, etc.',
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
                      const SizedBox(
                        height: 10.0,
                      ),
                      ElevatedButton(
                        onPressed: (!isUploading)
                        ? (){
                          if(imagePath == ''){
                            setState(() {
                              imageWarning = true;
                            });
                          }
                          if(_formKey.currentState!.validate() && imagePath != ''){
                            DateTime checkStartTime = DateTime.parse("${dateChoosen.year}-${dateChoosen.month.toString().padLeft(2, '0')}-${dateChoosen.day.toString().padLeft(2, '0')} ${startTimeChoosen.hour.toString().padLeft(2, '0')}:${startTimeChoosen.minute.toString().padLeft(2, '0')}:00");
                            DateTime checkEndTime = DateTime.parse("${dateChoosen.year}-${dateChoosen.month.toString().padLeft(2, '0')}-${dateChoosen.day.toString().padLeft(2, '0')} ${endTimeChoosen.hour.toString().padLeft(2, '0')}:${endTimeChoosen.minute.toString().padLeft(2, '0')}:00");
                            if(checkStartTime.isAfter(checkEndTime)){
                              showDialog(
                                barrierDismissible: false,
                                context: context, 
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Invalid Time'),
                                    content: const Text('Start Time lebih besar dari End Time'),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }, 
                                        child: const Text('OK')
                                      )
                                    ],
                                  );
                                },
                              );
                              return;
                            }
                            setState(() {
                              isUploading = true;
                            });
                            submit().then((value){
                              List result = jsonDecode(value) as List;
                              return showDialog(
                                barrierDismissible: false,
                                context: context, 
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(result[0]['title']),
                                    content: Text(result[0]['content']),
                                    actions: [
                                      TextButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Ok')
                                      ),
                                    ],
                                  );
                                },
                              );
                            });
                          }
                        }
                        : null,
                        child: (!isUploading)
                        ? const Text('Submit')
                        : const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator()
                        ),
                      ),
                    ],
                  ),
                ),
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
    );
  }
}