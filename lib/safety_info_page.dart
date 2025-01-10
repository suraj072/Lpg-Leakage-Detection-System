import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyInstructionsPage extends StatelessWidget {
  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Instructions'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Safety Instructions:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '1. Remain calm and assess the situation.\n'
              '2. Evacuate the area immediately if it is unsafe.\n'
              '3. Alert others nearby and help them evacuate if needed.\n'
              '4. Call emergency services (e.g., Fire Department, Police, or Ambulance).\n'
              '5. Avoid using elevators during emergencies.\n'
              '6. If there is a fire, cover your nose and mouth with a cloth and stay low to the ground.\n'
              '7. Follow the instructions of emergency personnel.\n',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _makePhoneCall('101'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Call Emergency',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SafetyInstructionsPage(),
  ));
}
