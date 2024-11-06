import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageDetail extends StatefulWidget {
  const ImageDetail({super.key, required this.image, required this.index});

  final List image;
  final int index;

  @override
  State<ImageDetail> createState() => _ImageDetail();
}

class _ImageDetail extends State<ImageDetail> {
  String page = '';

  @override
  void initState() {
    super.initState();
    page = '${widget.index+1} / ${widget.image.length}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.image.length,
            loadingBuilder: (context, event) {
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
            },
            pageController: PageController(
              initialPage: widget.index,
            ),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                minScale: PhotoViewComputedScale.contained * 1.0,
                imageProvider: NetworkImage('http://10.0.2.2/OHTM/room_image/${widget.image[index]['room_image']}'),
              );
            },
            onPageChanged: (index) {
              setState(() {
                page = '${index+1} / ${widget.image.length}';
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.grey.shade300,
              ),
              child: Text(page),
            ),
          )
        ],
      ),
    );
  }
}