import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:nutrilligent/screens/weight_selection_screen.dart';

class HeightSelectionScreen extends StatefulWidget {
  const HeightSelectionScreen({super.key});

  @override
  State<HeightSelectionScreen> createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen>
    with SingleTickerProviderStateMixin {
  int selectedMeters = 1;
  int selectedCentimeters = 50;
  bool _showExplanation = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveHeight() async {
    if (_auth.currentUser == null) return;

    String userId = _auth.currentUser!.uid;
    int totalHeightCm = (selectedMeters * 100) + selectedCentimeters;

    try {
      await _firestore.collection("users").doc(userId).update({
        "height": totalHeightCm,
      });

      logger.i(" Height saved: $totalHeightCm cm for user $userId");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Height saved successfully!")),
        );
      }

      // Navigare către următorul ecran
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WeightSelectionScreen()),
        );
      }
    } catch (e) {
      logger.e("Error saving height!", error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving height: ${e.toString()}")),
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Titlu
              Text(
                "How tall are you?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),

              Image.asset(
                'assets/images/height_icon.png', 
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPicker(
                    minValue: 1,
                    maxValue: 2,
                    selectedValue: selectedMeters,
                    onChanged: (value) {
                      setState(() {
                        selectedMeters = value;
                      });
                    },
                    unit: "m",
                  ),
                  SizedBox(width: 10),
                  _buildPicker(
                    minValue: 0,
                    maxValue: 99,
                    selectedValue: selectedCentimeters,
                    onChanged: (value) {
                      setState(() {
                        selectedCentimeters = value;
                      });
                    },
                    unit: "cm",
                  ),
                ],
              ),
              SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _showExplanation = !_showExplanation;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _showExplanation ? Colors.white10 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _showExplanation
                        ? "Your height affects your metabolism. Taller people generally have higher caloric needs."
                        : "Why we ask",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                      decoration: _showExplanation
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveHeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 188, 78, 184),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    "Next",
                    key: ValueKey("Next"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
    required String unit,
  }) {
    return Column(
      children: [
        Container(
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
            scrollController: FixedExtentScrollController(
              initialItem: selectedValue - minValue,
            ),
            itemExtent: 40,
            backgroundColor: Colors.black,
            onSelectedItemChanged: (index) {
              onChanged(index + minValue);
            },
            children: List.generate(
              maxValue - minValue + 1,
              (index) => Center(
                child: Text(
                  "${index + minValue} $unit",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}