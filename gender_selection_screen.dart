import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart'; 
import 'package:nutrilligent/screens/birthday_selection_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GenderSelectionScreenState();
  }
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger(); 
  String? _selectedGender;

  Future<void> _selectGender(String gender) async {
    setState(() {
      _selectedGender = gender;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "gender": gender,
      }, SetOptions(merge: true));

    //logger.i(" Gender saved: $gender for user ${user.uid}");
    }
  }

  void _goToNextScreen(BuildContext context) {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a gender!")),
      );
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BirthDateSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("What's Your", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white)),
            Text("Gender?", style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 188, 78, 184))),
            SizedBox(height: 20),
            Lottie.asset('assets/animations/gender_selection.json', height: 180),
            SizedBox(height: 20),
            Text("This helps us personalize your experience", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGenderButton("Male", Icons.male),
                _buildGenderButton("Female", Icons.female),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedGender != null ? () => _goToNextScreen(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 188, 78, 184),
                foregroundColor: Colors.white,
              ),
              child: Text("Next"),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
              },
              child: Text(
                "By continuing, you agree to our Privacy Policy & Terms",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 122, 149, 194),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon) {
    bool isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => _selectGender(gender),
      borderRadius: BorderRadius.circular(50),
      splashColor: Color.fromARGB(255, 188, 78, 184).withAlpha((0.3 * 255).toInt()),
      child: Container(
        width: 130,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 188, 78, 184) : Colors.white10,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white54, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(
              gender,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}