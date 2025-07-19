import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:nutrilligent/screens/target_weight_selection_screen.dart';

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen>
    with SingleTickerProviderStateMixin {
  double weight = 60;
  String selectedUnit = "kg";
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

  Future<void> _saveWeight() async {
    if (_auth.currentUser == null) return;

    String userId = _auth.currentUser!.uid;

    try {
      await _firestore.collection("users").doc(userId).update({
        "weight": weight,
        "weightUnit": selectedUnit,
      });

      logger
          .i("⚖️ Greutatea salvată: $weight $selectedUnit pentru user $userId");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Weight saved successfully!")),
         );
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TargetWeightScreen()),
        );
      }
    } catch (e) {
      logger.e("Error saving weight!", error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving weight: ${e.toString()}")),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "What's your weight?",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Lottie.asset(
                  'assets/animations/weight_animation.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  child: TextField(
                    controller: TextEditingController(
                        text: weight == 0 ? "" : weight.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40, color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        weight = double.tryParse(value) ?? 0;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Enter weight",
                      hintStyle: TextStyle(fontSize: 30, color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  fillColor: Color.fromARGB(255, 188, 78, 184),
                  selectedColor: Colors.white,
                  color: Colors.white70,
                  isSelected: [
                    selectedUnit == "kg",
                    selectedUnit == "lb",
                    selectedUnit == "st & lb",
                  ],
                  onPressed: (index) {
                    setState(() {
                      if (index == 0) selectedUnit = "kg";
                      if (index == 1) selectedUnit = "lb";
                      if (index == 2) selectedUnit = "st & lb";
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("kg"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("lb"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("st & lb"),
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
                      color: _showExplanation
                          ? Colors.white10
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _showExplanation
                          ? "Your weight is essential for accurate health recommendations."
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
                  onPressed: _saveWeight,
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
      ),
    );
  }
}
