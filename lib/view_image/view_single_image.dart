import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewSingleImage extends StatefulWidget {
  const ViewSingleImage({super.key, required this.address});

  final String address;

  @override
  State<ViewSingleImage> createState() => _ViewSingleImage();
}

class _ViewSingleImage extends State<ViewSingleImage> {

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
      body: PhotoViewGallery(
        pageOptions: [
          PhotoViewGalleryPageOptions(
            minScale: PhotoViewComputedScale.contained * 1.0,
            maxScale: PhotoViewComputedScale.contained * 5.0,
            imageProvider: NetworkImage(widget.address),
          ),
        ],
      ),
    );
  }
}