import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pencatatan_kinerja_ob/report/report_detail.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateReport extends StatefulWidget {
  const CreateReport({super.key});

  @override
  State<CreateReport> createState() => _CreateReport();
}

class _CreateReport extends State<CreateReport> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController remarks = TextEditingController();
  String roomID = '';
  String reportType = '';
  final alphanumeric = RegExp(r'^[a-zA-Z0-9.,/]+$');

  late SharedPreferences pref;
  String imagePath = '';
  bool imageWarning = false;

  bool isUploading = false;

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

  Future submit() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/create_report.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['id'] = pref.getString('id')!;
    request.fields['room_id'] = roomID;
    request.fields['remarks'] = remarks.text;
    request.fields['report_type'] = reportType;
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
        title: const Text('Create Report'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/create_report.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],  
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: Future.wait([getRoomList(), getReportTypeList()]), 
          builder: (context, snapshot) {
            if(snapshot.hasData){
              List roomList = jsonDecode(snapshot.data![0]) as List;
              List reportTypeList = jsonDecode(snapshot.data![1]) as List;
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
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
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.40,
                            height: MediaQuery.of(context).size.width * 0.50,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.black,
                                  ),
                                  Text('Take a picture'),
                                ],
                              ),
                            ),
                          )
                        )
                        : Image.file(
                          File(imagePath),
                          width: MediaQuery.of(context).size.width * 0.40,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonFormField(
                          isDense: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
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
                      ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            label: const Text('Select Report Type'),
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
                              value: reportTypeList[i]['report_type_id'],
                              child: Text('${reportTypeList[i]['report_type_name']}'),
                            )
                          ], 
                          onChanged: (value) {
                            setState(() {
                              reportType = value.toString();
                            });
                          },
                          value: '',
                          validator: (value) {
                            if (value == '') {
                              return 'Please select Report Type';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: remarks,
                        maxLines: null,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          label: const Text('Report remarks'),
                          hintText: 'Report remarks',
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
                            setState(() {
                              isUploading = true;
                            });
                            submit().then((value){
                              Map result = jsonDecode(value) as Map;
                              return showDialog(
                                barrierDismissible: false,
                                context: context, 
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(result['title']),
                                    content: Text(result['content']),
                                    actions: [
                                      TextButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context, 
                                            MaterialPageRoute(builder: (context) => ReportDetail(reportID: result['report_id']),)
                                          );
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