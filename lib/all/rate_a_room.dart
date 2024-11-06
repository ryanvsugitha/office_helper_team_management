import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/employee_pages.dart/employee_main.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateARoom extends StatefulWidget {
  const RateARoom({super.key, required this.roomID});

  final String roomID;

  @override
  State<RateARoom> createState() => _RateARoom();
}

class _RateARoom extends State<RateARoom> {

  final _formKey = GlobalKey<FormState>();
  final alphanumeric = RegExp(r'^[a-zA-Z0-9.,/]+$');

  TextEditingController remarks = TextEditingController();

  int rate = 0;
  int currIndex = 0;

  late SharedPreferences pref;

  bool isUploading = false;

  Future getRoom() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_detail.php');
    var request = await http.post(url, body: {
      'room_id': widget.roomID,
    });
    return request.body;
  }

  Future getRoomImage() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_image.php');
    var request = await http.post(url, body: {
      'room_id': widget.roomID,
    });
    return request.body;
  }

  Future submit() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/OHTM/room_submit_rating.php');
    var request = await http.post(url, body: {
      'id': pref.getString('id'),
      'room_id': widget.roomID,
      'rate': rate.toString(),
      'remarks': remarks.text
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate a Room'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/rate_a_room.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([getRoom(), getRoomImage()]),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data![0]) as List;
            List image = jsonDecode(snapshot.data![1]) as List;
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 8),
                    child: CarouselSlider.builder(
                      itemCount: image.length,
                      options: CarouselOptions(
                        scrollDirection: Axis.horizontal,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        onPageChanged: (index, reason) {
                          setState(() {
                            currIndex = index;
                          });
                        },
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return CachedNetworkImage(
                          imageUrl: 'http://10.0.2.2/OHTM/room_image/${image[index]['room_image']}',
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
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for(int i = 0; i<image.length; i++)
                      Container(
                        margin: const EdgeInsets.only(right: 2.0, left: 2.0),
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (currIndex == i)
                          ? const Color.fromRGBO(0, 0, 0, 0.9)
                          : const Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Colors.white,
                  ),
                  Detail(
                    leading: Icons.home_work_rounded, 
                    title: 'Room ID - Room Name', 
                    content: Text('${result[0]['room_id']} - ${result[0]['room_name']}')
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Colors.white,
                  ),
                  Detail(
                    leading: Icons.star_rounded, 
                    title: 'Room Rating', 
                    content: Row(
                      children: [
                        Text(
                          (result[0]['rating'] != null)
                          ? result[0]['rating']
                          : 'No Rating',
                        ),
                        (result[0]['rating'] != null)
                        ? RatingBarIndicator(
                          rating: double.parse(result[0]['rating']),
                          itemBuilder: (context, index) {
                            return const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                            );
                          },
                        )
                        : Container(),
                      ],
                    )
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Colors.white,
                  ),
                  Detail(
                    leading: Icons.location_on_rounded, 
                    title: 'Room Location', 
                    content: Text(
                      (result[0]['room_location_desc'] == null)
                      ? result[0]['loc_name']
                      : '${result[0]['loc_name']}, ${result[0]['room_location_desc']}',
                    ),
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Colors.white,
                  ),
                  Detail(
                    leading: Icons.chat_rounded, 
                    title: 'Room Description', 
                    content: Text(result[0]['room_desc'])
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Colors.white,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xffF5F5F5),
                    child: Column(
                      children: [
                        const Center(
                          child: Text(
                            'Please give your rate for this room',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: RatingBar.builder(
                            glow: false,
                            minRating: 1,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,  
                              );
                            }, 
                            onRatingUpdate: (value) {
                              setState(() {
                                rate = value.toInt();
                              });
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
                            label: const Text('Rate remarks'),
                            hintText: 'Ruangan bersih, dll.',
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
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: (!isUploading)
                      ? () {
                        if(_formKey.currentState!.validate() && rate != 0){
                          setState(() {
                            isUploading = true;
                          });
                          submit().then((value){
                            List submit = jsonDecode(value) as List;
                            showDialog(
                              barrierDismissible: false,
                              context: context, 
                              builder: (context) {
                                return AlertDialog(
                                  actionsAlignment: MainAxisAlignment.center,
                                  title: Text(submit[0]['title']),
                                  content: Text(submit[0]['content']),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if(submit[0]['result'] == 1){
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const EmployeeMain(),
                                            ),
                                            (route) => false,
                                          );
                                        } else {
                                          setState(() {
                                            isUploading = false;
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('OK')
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
                  ),
                  const SizedBox(
                    height: 10.0,
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