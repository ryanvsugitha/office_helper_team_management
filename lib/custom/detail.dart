import 'package:flutter/material.dart';

class Detail extends StatelessWidget {
  const Detail({super.key, required this.leading, required this.title, required this.content,  this.warning});

  final IconData leading;
  final String title;
  final Widget content;
  final bool? warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xffF5F5F5),
      child: Row(
        children: [
          Icon(
            leading,
            color: const Color(0xff45A4F0),
            size: 30,
          ),
          const SizedBox(
            width: 8.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
                content,
              ],
            ),
          ),
          (warning == true)
          ? const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          )
          : Container(),
        ],
      ),
    );
  }
}