import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart'; 
import 'package:nutrilligent/screens/customize_app_screen.dart'; 

class ActivityLevelSelectionScreen extends StatefulWidget {
  const ActivityLevelSelectionScreen({super.key});

  @override
  State<ActivityLevelSelectionScreen> createState() => _ActivityLevelSelectionScreenState();
}

class _ActivityLevelSelectionScreenState extends State<ActivityLevelSelectionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  String? _selectedActivityLevel;
  final List<Map<String, dynamic>> _activityLevels = [
    {
      "name": "Sedentary",
      "icon": Icons.airline_seat_individual_suite, 
      "description": "Little or no exercise",
    },
    {
      "name": "Light",
      "icon": Icons.directions_walk, 
      "description": "Light exercise 1-3 days/week",
    },
    {
      "name": "Moderate",
      "icon": Icons.directions_run, 
      "description": "Moderate exercise 3-5 days/week",
    },
    {
      "name": "Active",
      "icon": Icons.fitness_center, 
      "description": "Hard exercise 6-7 days/week",
    },
  ];

  Future<void> _saveActivityLevel() async {
    if (_auth.currentUser == null || _selectedActivityLevel == null) return;

    String userId = _auth.currentUser!.uid;

    try {
      await _firestore.collection("users").doc(userId).update({
        "activityLevel": _selectedActivityLevel!.toLowerCase(),
      });

     // logger.i(" Activity level saved: $_selectedActivityLevel for user $userId");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Activity level saved successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomizingScreen()),
        );
      }
    } catch (e) {
      logger.e(" Error saving activity level", error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving activity level: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Titlu
            Text(
              "Select Your Activity Level",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),

            Text(
              "This helps us calculate your daily calorie needs more accurately.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20),

            Lottie.asset(
              'assets/animations/activity_level.json', 
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Column(
              children: _activityLevels.map((level) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedActivityLevel = level["name"];
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedActivityLevel == level["name"]
                          ? Color.fromARGB(255, 188, 78, 184) 
                          : Colors.white10, 
                      minimumSize: Size(double.infinity, 70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(level["icon"], color: Colors.white),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level["name"],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              level["description"],
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 32),

            //"Next"
            ElevatedButton(
              onPressed: _selectedActivityLevel != null ? _saveActivityLevel : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 188, 78, 184),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Next",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}