import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:pencatatan_kinerja_ob/custom/detail.dart';
import 'package:pencatatan_kinerja_ob/room_info/room_info_view.dart';
import 'package:pencatatan_kinerja_ob/view_image/view_single_image.dart';
import 'package:pencatatan_kinerja_ob/view_pdf/view_pdf.dart';

class RoomInformationDetail extends StatefulWidget {
  const RoomInformationDetail({super.key, required this.roomID, required this.roomName});

  final String roomID;
  final String roomName;

  @override
  State<RoomInformationDetail> createState() => _RoomInformationDetail();
}

class _RoomInformationDetail extends State<RoomInformationDetail> {
  int currIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Detail'),
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
        future: Future.wait([getRoom(), getRoomImage()]),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data![0]) as List;
            List image = jsonDecode(snapshot.data![1]) as List;
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageDetail(image: image, index: currIndex),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: 'http://10.0.2.2/OHTM/room_image/${image[index]['room_image']}',
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
                        )
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
                                ? const Color(0xff45A4F0)
                                : const Color.fromRGBO(0, 0, 0, 0.2),
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
                  leading: Icons.star_rate_rounded, 
                  title: 'Room Rating', 
                  content: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        (result[0]['rating'] != null)
                        ? result[0]['rating']
                        : 'No Rating',
                      ),
                      (result[0]['rating'] != null)
                      ? RatingBarIndicator(
                        itemSize: 30,
                        rating: double.parse(result[0]['rating']),
                        itemBuilder: (context, index) {
                          return const Icon(
                            Icons.star_rate_rounded,
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
                  leading: Icons.chat_rounded, 
                  title: 'Room Description', 
                  content: Text(result[0]['room_desc'])
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.white,
                ),
                Detail(
                  leading: Icons.location_on, 
                  title: 'Room Location', 
                  content: Column(
                    children: [
                      Text(
                        (result[0]['room_location_desc'] == null)
                        ? result[0]['loc_name']
                        : '${result[0]['loc_name']}, ${result[0]['room_location_desc']}',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
                  height: MediaQuery.of(context).size.width * 0.3,
                  width: MediaQuery.of(context).size.width,
                  decoration:  const BoxDecoration(
                    color: Color(0xffF5F5F5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewSingleImage(address: 'http://10.0.2.2/OHTM/room_image/${result[0]['room_map']}'),
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: 'http://10.0.2.2/OHTM/room_image/${result[0]['room_map']}',
                      progressIndicatorBuilder: (context, url, progress) => Center(
                        child: CircularProgressIndicator(value: progress.progress),
                      ),
                      imageBuilder: (context, imageProvider) => Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover
                              )
                            ),
                          ),
                          Container(
                            decoration:  BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: const Color.fromARGB(150, 27, 27, 27),
                            ),
                          ),
                          const Center(
                            child: Text(
                              'See Detail',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                ),
              ],
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