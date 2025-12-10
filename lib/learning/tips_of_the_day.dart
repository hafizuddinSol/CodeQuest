import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class TipsOfTheDay extends StatefulWidget {
  const TipsOfTheDay({super.key});

  @override
  State<TipsOfTheDay> createState() => _TipsOfTheDayState();
}

class _TipsOfTheDayState extends State<TipsOfTheDay> {
  String todayTip = "Loading tip...";

  @override
  void initState() {
    super.initState();
    _fetchTipFromFirestore();
  }

  Future<void> _fetchTipFromFirestore() async {
    try {
      // Fetch tips with DisplayFrequency = Daily from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('tips')
          .where('DisplayFrequency', isEqualTo: 'Daily')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docs = snapshot.docs;

        // Generate a random tip using today as seed
        final random = Random(DateTime.now().day +
            DateTime.now().month +
            DateTime.now().year);

        final randomTip =
            docs[random.nextInt(docs.length)]['message'] ?? "No tip found";

        setState(() {
          todayTip = randomTip;
        });
      } else {
        setState(() {
          todayTip = "No tips available today.";
        });
      }
    } catch (e) {
      setState(() {
        todayTip = "Error loading tip: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "💡 Tip of the Day",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            todayTip,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}