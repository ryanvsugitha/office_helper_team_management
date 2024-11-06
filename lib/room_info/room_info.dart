import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_kinerja_ob/room_info/room_info_detail.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class RoomInformation extends StatefulWidget{
  const RoomInformation({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RoomInformation();
  }
}

class _RoomInformation extends State<RoomInformation>{

  Future getRoom() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_all.php');
    var request = await http.post(url, body: {});
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Information'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/room_information.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: getRoom(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data) as List;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: result.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomInformationDetail(roomID: result[index]['room_id'], roomName: result[index]['room_name'],),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.25,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: CachedNetworkImage(
                              imageUrl: 'http://10.0.2.2/OHTM/room_image/${result[index]['room_image']}',
                              progressIndicatorBuilder: (context, url, progress) => Center(
                                child: CircularProgressIndicator(value: progress.progress),
                              ),
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover
                                  )
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:  [
                                Text(
                                  '${result[index]['room_name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  result[index]['room_id'],
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xff45A4F0),
                                    ),
                                    Expanded(
                                      child: Text(result[index]['loc_name']),
                                    ),
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