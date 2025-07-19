import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:nutrilligent/screens/height_selection_screen.dart';

class BirthDateSelectionScreen extends StatefulWidget {
  const BirthDateSelectionScreen({super.key});

  @override
  State<BirthDateSelectionScreen> createState() =>
      _BirthDateSelectionScreenState();
}

class _BirthDateSelectionScreenState extends State<BirthDateSelectionScreen>
    with SingleTickerProviderStateMixin {
  int selectedDay = 1;
  int selectedMonth = 1;
  int selectedYear = 2000;
  bool _showExplanation = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  final List<String> _monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveBirthDate() async {
    if (_auth.currentUser == null) return;

    String userId = _auth.currentUser!.uid;
    String birthDate =
        "$selectedDay-${_monthNames[selectedMonth - 1]}-$selectedYear";

    try {
      await _firestore.collection("users").doc(userId).update({
        "birthDate": birthDate,
      });

    //  logger.i(" Birthdate saved: $birthDate for user $userId");

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HeightSelectionScreen()),
        );
      }
    } catch (e) {
      logger.e(" Error saving birthdate", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving birthdate: ${e.toString()}")),
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
            onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("When were you born?",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 12),
              Lottie.asset('assets/animations/birthday_animation.json',
                  width: 150, height: 150, fit: BoxFit.contain),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPicker(
                      minValue: 1,
                      maxValue: 31,
                      selectedValue: selectedDay,
                      onChanged: (value) => setState(() => selectedDay = value),
                      customLabels: null),
                  SizedBox(width: 10),
                  _buildPicker(
                      minValue: 1,
                      maxValue: 12,
                      selectedValue: selectedMonth,
                      onChanged: (value) =>
                          setState(() => selectedMonth = value),
                      customLabels: _monthNames),
                  SizedBox(width: 10),
                  _buildPicker(
                      minValue: 1900,
                      maxValue: DateTime.now().year,
                      selectedValue: selectedYear,
                      onChanged: (value) =>
                          setState(() => selectedYear = value),
                      customLabels: null),
                ],
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    setState(() => _showExplanation = !_showExplanation),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _showExplanation ? Colors.white10 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _showExplanation
                        ? "Your birthdate is important to provide accurate health and nutrition recommendations."
                        : "Why we ask",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                        decoration: _showExplanation
                            ? TextDecoration.none
                            : TextDecoration.underline),
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBirthDate,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 188, 78, 184),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    "Next",
                    key: ValueKey("Next"),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPicker({
    required int minValue,
    required int maxValue,
    required int selectedValue,
    required Function(int) onChanged,
    List<String>? customLabels,
  }) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(255, 255, 255, 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
      ),
      child: CupertinoPicker(
        scrollController:
            FixedExtentScrollController(initialItem: selectedValue - minValue),
        itemExtent: 40,
        backgroundColor: Colors.black,
        onSelectedItemChanged: (index) => onChanged(index + minValue),
        children: List.generate(
          maxValue - minValue + 1,
          (index) => Center(
              child: Text(
                  customLabels != null
                      ? customLabels[index]
                      : "${index + minValue}",
                  style: TextStyle(color: Colors.white, fontSize: 20))),
        ),
      ),
    );
  }
}