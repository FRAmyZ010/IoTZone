import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ส่วนบน 30%
            Expanded(
              flex: 20, // 30%
              child: Container(
                color: Colors.deepPurple[200],
                child: Center(
                  child: Text(
                    'ส่วนบน (20%)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // ส่วนล่าง 70%
            Expanded(
              flex: 80, // 70%
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    'ส่วนล่าง (80%)',
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
