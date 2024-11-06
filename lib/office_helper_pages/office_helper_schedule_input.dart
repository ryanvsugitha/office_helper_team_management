import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/office_helper_pages/office_helper_schedule_detail.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OHScheduleInput extends StatefulWidget{
  const OHScheduleInput({super.key, required this.date, required this.startTime});

  final String date;
  final String startTime;

  @override
  State<StatefulWidget> createState() {
    return _OHScheduleInput();
  }
}

class _OHScheduleInput extends State<OHScheduleInput>{

  final _formKey = GlobalKey<FormState>();
  String imagePath = '';
  String lateReason = '0';
  String roomID = '0';
  bool imageWarning = false;
  final alphanumeric = RegExp(r'^[a-zA-Z0-9.,/]+$');

  TextEditingController remarks = TextEditingController();

  bool isUploading = false;
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

  Future getLateType() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/get_late_type.php');
    var request = await http.post(url, body: {});
    return request.body;
  }

  Future getRoom() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_all.php');
    var request = await http.post(url, body: {});
    return request.body;
  }

  Future submit() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/oh_submit_daily_task.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['oh_id'] = pref.getString('id')!;
    request.fields['date'] = widget.date;
    request.fields['start_time'] = widget.startTime;
    request.fields['late_reason'] = lateReason;
    request.fields['oh_remarks'] = remarks.text;
    request.fields['room_id'] = roomID;
    request.files.add(await http.MultipartFile.fromPath(
      'report_file',
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
          future: Future.wait([getScheduleDetail(), getLateType(), getRoom()]),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              List result = jsonDecode(snapshot.data![0]) as List;
              List lateType = jsonDecode(snapshot.data![1]) as List;
              List room = jsonDecode(snapshot.data![2]) as List;
              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          height: MediaQuery.of(context).size.width * 0.40,
                          width: MediaQuery.of(context).size.width * 0.30,
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
                            child: (imagePath == '')
                            ? DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10.0),
                              dashPattern: const [10, 4],
                              strokeWidth: 2.0,
                              color: (imageWarning)
                              ? Colors.red
                              : Colors.black,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      color: (imageWarning)
                                        ? Colors.red
                                        : Colors.black
                                    ),
                                    Text(
                                      'Take a picture',
                                      style: TextStyle(
                                        color: (imageWarning)
                                        ? Colors.red
                                        : Colors.black
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              )
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.file(
                                File(imagePath),
                                fit: BoxFit.cover
                              ),
                            )
                          )
                        ),
                        const SizedBox(
                          width: 4.0,
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
                                    color: (result[0]['oh_status'] == 'Late' || result[0]['oh_status'] == 'Late/Not Submitted')
                                    ? Colors.red.shade400
                                    : Colors.amber
                                  ),
                                  child: Text(
                                    result[0]['oh_status'],
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
                                    color: Colors.grey.shade400
                                  ),
                                  child: Text(result[0]['sv_status'])
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
                    (result[0]['oh_status'] == 'Late/Not Submitted')
                    ? Detail(
                      leading: Icons.access_time_filled_rounded, 
                      title: 'Late Reason',
                      content: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonFormField(
                          value: '',
                          items: [
                            const DropdownMenuItem(
                              enabled: false,
                              value: '',
                              child: Text(
                                'Select Late Reason',
                                style: TextStyle(
                                  color: Colors.grey
                                ),
                              ),
                            ),
                            for(int i=0; i<lateType.length; i++)
                            DropdownMenuItem(
                              value: lateType[i]['reason_id'],
                              child: Text(lateType[i]['reason_name'])
                            ),
                          ],
                          onChanged: (value) {
                            lateReason = value.toString();
                          },
                          validator: (value) {
                              if(value == '' || value == null){
                                return 'Please input room';
                              }
                              return null;
                            },
                        ),
                      )
                    )
                    : Container(),
                    (result[0]['oh_status'] == 'Late/Not Submitted')
                    ? const Divider(
                      height: 4,
                      thickness: 4,
                      color: Colors.white,
                    )
                    : Container(),
                    Detail(
                      leading: Icons.location_on_rounded, 
                      title: 'Location',
                      content: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonFormField(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          value: '',
                          items: [
                            const DropdownMenuItem(
                              enabled: false,
                              value: '',
                              child: Text(
                                'Select Room',
                                style: TextStyle(
                                  color: Colors.grey
                                ),
                              ),
                            ),
                            for(int i=0; i<room.length; i++)
                            DropdownMenuItem(
                              value: room[i]['room_id'],
                              child: Text('${room[i]['room_id']} - ${room[i]['room_name']}')
                            )
                          ],
                          onChanged: (value) {
                            setState(() {
                              roomID = value.toString();
                            });
                          },
                          validator: (value) {
                            if(value == '' || value == null){
                              return 'Please input room';
                            }
                            return null;
                          },
                        ),
                      )
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
                      leading: Icons.clean_hands_rounded, 
                      title: "Office Helper's Remarks", 
                      content: TextFormField(
                        controller: remarks,
                        decoration: const InputDecoration(
                          hintText: 'Sudah dikerjakan, etc.'
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
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: (!isUploading)
                        ? (){
                          if(imagePath == ''){
                            setState(() {
                              imageWarning = true;
                            });
                          }
                          if(_formKey.currentState!.validate() && imagePath != ''){
                            setState(() {
                              isUploading = true;
                            });
                            submit().then((value){
                              Map result = jsonDecode(value) as Map;
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(result['title']),
                                    content: Text(result['message']),
                                    actions: [
                                      TextButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                          if(result['result'] == '1'){
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => OHScheduleDetail(date: widget.date, startTime: widget.startTime),)
                                            );
                                          }
                                        },
                                        child: const Text('OK')
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
                    ),
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
    );
  }
}
