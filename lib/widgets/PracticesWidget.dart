import 'package:flutter/material.dart';

import '../theme/app_themes.dart';

class PracticesWidget extends StatefulWidget {
  const PracticesWidget({super.key});

  @override
  State<PracticesWidget> createState() => _PracticesWidgetState();
}

class _PracticesWidgetState extends State<PracticesWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildPractice();
  }

  Widget _buildPractice() {
    return Container(
      margin: const EdgeInsets.all(50),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 2),
          image: const DecorationImage(
              image: AssetImage("assets/bg_practice.png"), fit: BoxFit.fill)),
      child: Column(
        children: [
          _partItem()
        ],
      ),
    );
  }

  Widget _partItem() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          
        ],
      ),
    );
  }
}
