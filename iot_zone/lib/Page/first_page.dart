import 'package:flutter/material.dart';
import 'package:iot_zone/Page/homepage.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Role Selection (for presentation)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Homepage()),
                    );
                  },
                  child: Text('Student'),
                ),
                FilledButton(onPressed: () {}, child: Text('Lender')),
                FilledButton(onPressed: () {}, child: Text('Staff')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
