import 'package:flutter/material.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Card(
            color: Colors.amber,
            child: Text("Test", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
