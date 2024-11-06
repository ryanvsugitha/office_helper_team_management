import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class SPVOHDetail extends StatefulWidget {
  const SPVOHDetail({super.key, required this.officeHelperID});

  final String officeHelperID;

  @override
  State<SPVOHDetail> createState() => _SPVOHDetail();
}

class _SPVOHDetail extends State<SPVOHDetail> {

  Future getOHDetail() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/oh_get_profile.php');
    var request = await http.post(url, body: { 
      'id': widget.officeHelperID,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Helper Detail'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewPDF(pdfURL: 'http://10.0.2.2/OHTM/user_guide/spv_oh_info.pdf'),)
              );
            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: getOHDetail(), 
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
              return ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.65,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: CachedNetworkImage(
                        imageUrl: 'http://10.0.2.2/OHTM/profile_image/${result[0]['oh_image']}',
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
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Column(
                    children: [
                      Text(
                        result[0]['oh_id'],
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        result[0]['oh_name'],
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        'Joined on ${result[0]['join_date']}',
                        style: const TextStyle(
                          color: Color(0xff9D9D9D)
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ],
              );
            }
          }
        },
      )
    );
  }
}