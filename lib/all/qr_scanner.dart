import 'dart:convert';

import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScanner();
}

class _QRScanner extends State<QRScanner> {

  Future getRoom() async {
    var url = Uri.parse('http://10.0.2.2/OHTM/room_get_all.php');
    var request = await http.post(url, body: {});
    return request.body;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code Room'),
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
        future: getRoom(),
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
              List roomList = [];
              for(int i = 0; i<result.length; i++){
                roomList.add(result[i]['room_id']);
              }
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      var result = await BarcodeScanner.scan();

                                      print(result.type); // The result type (barcode, cancelled, failed)
                                      print(result.rawContent); // The barcode content
                                      print(result.format); // The barcode format (as enum)
                                      print(result.formatNote);
                      },
                    child: Text('record')
                  )
                ],
              );
            }
          }
        },
      )
    );
  }
}