import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/all/rate_a_room.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class RoomScanner extends StatefulWidget {
  const RoomScanner({super.key});

  @override
  State<RoomScanner> createState() => _RoomScanner();
}

class _RoomScanner extends State<RoomScanner> {

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
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  MobileScanner(
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.normal,
                      detectionTimeoutMs: 100
                    ),
                    onDetect: (barcodes) {
                      List<Barcode> scannedRoom = barcodes.barcodes;
                      for(final room in scannedRoom){
                        String selectedRoom = room.rawValue!;
                        if(roomList.contains(selectedRoom)){
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RateARoom(roomID: selectedRoom),)
                          );
                        }
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      8.0,
                      0,
                      8.0,
                      MediaQuery.of(context).size.height * 0.20
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey.shade200
                      ),
                      child: const Text(
                        'Please scan QR Code on room',
                        textAlign: TextAlign.center,
                      ),
                    ),
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