import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_additional_task_detail.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPVCreateAddTask extends StatefulWidget {
  const SPVCreateAddTask({super.key, required this.ohID});

  final String ohID;

  @override
  State<SPVCreateAddTask> createState() => _SPVCreateAddTask();
}

class _SPVCreateAddTask extends State<SPVCreateAddTask> {

  List dayName = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  String imagePath = '';
  TextEditingController dateController = TextEditingController();
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();
  TextEditingController detailTask = TextEditingController();
  TextEditingController remarks = TextEditingController();

  DateTime chosenDate = DateTime.now();
  TimeOfDay chosenStartTime = TimeOfDay.now();
  TimeOfDay chosenEndTime = TimeOfDay.now();

  String roomID = '';

  bool imgWarning = false;

  final _formKey = GlobalKey<FormState>();

  bool isUploading = false;
  final alphanumeric = RegExp(r'^[a-zA-Z0-9.,/]+$');
  late SharedPreferences pref;

  Future getRoom() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_all.php');
    var request = await http.post(url, body: {});
    return request.body;
  }

  Future submit() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/spv_create_add_task.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['oh_id'] = widget.ohID;
    request.fields['requester_id'] = pref.getString('id')!;
    request.fields['date'] = '${chosenDate.year}-${chosenDate.month.toString().padLeft(2, '0')}-${chosenDate.day.toString().padLeft(2, '0')}';
    request.fields['start_time'] = startTime.text;
    request.fields['end_time'] = endTime.text;
    request.fields['task_detail'] = detailTask.text;
    request.fields['room_id'] = roomID;
    request.files.add(await http.MultipartFile.fromPath(
      'report_file',
      imagePath,
    ));

    var res = await request.send();
    var body = await http.Response.fromStream(res);
    return body.body;
  }

  late Future getroom;

  @override
  void initState() {
    super.initState();
    getroom = getRoom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Additional Task'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/spv_create_add_task.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: FutureBuilder(
          future: Future.wait([getroom]), 
          builder: (context, snapshot) {
            if(snapshot.hasData){
              List room = jsonDecode(snapshot.data![0]) as List;
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    Center(
                      child: InkWell(
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
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.50 * 3/4,
                          height: MediaQuery.of(context).size.width * 0.50,
                          child: (imagePath != '')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.file(File(imagePath)),
                            )
                          : DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10.0),
                            dashPattern: const [10, 4],
                            strokeWidth: 2.0,
                            color: (imgWarning)
                            ? Colors.red
                            : Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    color: (imgWarning)
                                    ? Colors.red
                                    : Colors.black,
                                  ),
                                  Text(
                                    'Take image',
                                    style: TextStyle(
                                      color: (imgWarning)
                                      ? Colors.red
                                      : Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    TextFormField(
                      controller: dateController,
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030)
                        );
                        if(date != null){
                          chosenDate = date;
                          dateController.text = '${dayName[date.weekday]}, ${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString()}';
                        }
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        label: const Text('Date'),
                        prefixIcon: const Icon(Icons.calendar_month_rounded)
                      ),
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
                                chosenStartTime = time;
                                startTime.text = '${chosenStartTime.hour.toString().padLeft(2, '0')}:${chosenStartTime.minute.toString().padLeft(2, '0')}:00';
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
                                chosenEndTime = time;
                                endTime.text = '${chosenEndTime.hour.toString().padLeft(2, '0')}:${chosenEndTime.minute.toString().padLeft(2, '0')}:00';
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
                    DropdownButtonFormField(
                      value: '',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        label: const Text('Room'),
                        prefixIcon: const Icon(Icons.location_on_rounded),
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
                        for(int i=0; i<room.length; i++)
                        DropdownMenuItem(
                          value: room[i]['room_id'],
                          child: Text('${room[i]['room_id']} - ${room[i]['room_name']}'),
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          roomID = value.toString();
                        });
                      },
                      validator: (value) {
                        if(value == null || value == ''){
                          return 'Please select room';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      controller: detailTask,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        label: const Text('Task Detail'),
                        hintText: 'Task detail, Requester, etc',
                        prefixIcon: const Icon(Icons.clean_hands_rounded),
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
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: (!isUploading)
                          ? (){
                            if(imagePath == ''){
                              setState(() {
                                imgWarning = true;
                              });
                            }
                            if(_formKey.currentState!.validate()){
                              DateTime checkStartTime = DateTime.parse("${chosenDate.year}-${chosenDate.month.toString().padLeft(2, '0')}-${chosenDate.day.toString().padLeft(2, '0')} ${chosenStartTime.hour.toString().padLeft(2, '0')}:${chosenStartTime.minute.toString().padLeft(2, '0')}:00");
                              DateTime checkEndTime = DateTime.parse("${chosenDate.year}-${chosenDate.month.toString().padLeft(2, '0')}-${chosenDate.day.toString().padLeft(2, '0')} ${chosenEndTime.hour.toString().padLeft(2, '0')}:${chosenEndTime.minute.toString().padLeft(2, '0')}:00");
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
                                showDialog(
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
                                            if(result[0]['result'] == '1'){
                                              Navigator.pushReplacement(
                                                context, 
                                                MaterialPageRoute(builder: (context) => OHAddTaskDetail(reqID: result[0]['id']),)
                                              );
                                            }
                                          }, 
                                          child: const Text('OK'),
                                        )
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
                    )
                  ],
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
        ),
      ),
    );
  }
}