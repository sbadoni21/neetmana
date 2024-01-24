import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  Timestamp timestamp;
  bool seen;

  String timeStampToDateTime() {
    tzdata.initializeTimeZones();
    final String sourceTimeZone = 'UTC'; // UTC time
    final String targetTimeZone = 'Asia/Kolkata';
    final TZDateTime sourceTime = TZDateTime.fromMillisecondsSinceEpoch(
        getLocation(sourceTimeZone), timestamp.millisecondsSinceEpoch);
    final istTime = sourceTime.add(const Duration(hours: 5, minutes: 30));
    final String formattedISTTime = DateFormat('hh:mm a').format(istTime);
    return formattedISTTime;
  }

  ChatBubble(
      {super.key,
      required this.message,
      required this.seen,
      required this.timestamp});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: seen ? Colors.blue : Colors.greenAccent),
            child: Text(
              message,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              timeStampToDateTime(),
              style: const TextStyle(
                fontSize: 8,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
