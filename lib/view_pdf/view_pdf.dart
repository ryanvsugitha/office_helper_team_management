import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class ViewPDF extends StatefulWidget {
  const ViewPDF({super.key, required this.pdfURL});

  final String pdfURL;

  @override
  State<ViewPDF> createState() => _ViewPDF();
}

class _ViewPDF extends State<ViewPDF> {

  String currPage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'User Guide',
          style: TextStyle(
            color: Colors.black
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PDF(
            enableSwipe: true,
            swipeHorizontal: true,
            onPageChanged: (page, total) {
              setState(() {
                currPage = '${ page! + 1} / ${total!}';
              });
            },
          ).cachedFromUrl(
            widget.pdfURL,
            placeholder: (progress) => Center(child: CircularProgressIndicator(value: progress,),),
            errorWidget: (error) => Center(child: Text(error.toString()),),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              8.0,
              0,
              8.0,
              MediaQuery.of(context).size.height * 0.05
            ),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade200
              ),
              child: Text(
                currPage,
                textAlign: TextAlign.center,
              ),
            ),
        
          ),
        ],
      ),
    );
  }
}