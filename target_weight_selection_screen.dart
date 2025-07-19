import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:nutrilligent/screens/activity_level_screen.dart';
import 'dart:async';

class TargetWeightScreen extends StatefulWidget {
  const TargetWeightScreen({super.key});

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ValueNotifier<double> _targetWeightNotifier = ValueNotifier<double>(60);
  final ValueNotifier<String> _selectedUnitNotifier =
      ValueNotifier<String>("kg");
  final TextEditingController _weightController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final ValueNotifier<bool> _showExplanationNotifier =
      ValueNotifier<bool>(false);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _weightController.text = _targetWeightNotifier.value.toString();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _targetWeightNotifier.dispose();
    _selectedUnitNotifier.dispose();
    _showExplanationNotifier.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _saveTargetWeight() async {
    if (_auth.currentUser == null) return;

    String userId = _auth.currentUser!.uid;

    try {
      await _firestore.collection("users").doc(userId).update({
        "targetWeight":
            "${_targetWeightNotifier.value} ${_selectedUnitNotifier.value}",
      });

      _logger.i(
          "Error saving target weight: ${_targetWeightNotifier.value} ${_selectedUnitNotifier.value} for user $userId");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Target weight saved successfully!")),
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ActivityLevelSelectionScreen()),
        );
      }
    } catch (e) {
      _logger.e("Error saving target weight", error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error saving target weight: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Enter your target weight",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Lottie.asset(
                'assets/animations/target_weight.json',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80, 
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _targetWeightNotifier.value = double.tryParse(value) ?? 0;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Enter weight",
                    hintStyle: TextStyle(fontSize: 30, color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: _selectedUnitNotifier,
                builder: (context, selectedUnit, _) {
                  return ToggleButtons(
                    borderRadius: BorderRadius.circular(12),
                    fillColor: Colors.blueGrey,
                    selectedColor: Colors.white,
                    color: Colors.white70,
                    isSelected: [
                      selectedUnit == "kg",
                      selectedUnit == "lb",
                      selectedUnit == "st & lb",
                    ],
                    onPressed: (index) {
                      if (index == 0) _selectedUnitNotifier.value = "kg";
                      if (index == 1) _selectedUnitNotifier.value = "lb";
                      if (index == 2) _selectedUnitNotifier.value = "st & lb";
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("kg"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("lb"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("st & lb"),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _showExplanationNotifier,
                builder: (context, showExplanation, _) {
                  return GestureDetector(
                    onTap: () {
                      _showExplanationNotifier.value = !showExplanation;
                    },
                    child: Text(
                      showExplanation
                          ? "Your target weight helps us personalize your nutrition and fitness plans."
                          : "Why we ask",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                        decoration: showExplanation
                            ? TextDecoration.none
                            : TextDecoration.underline,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTargetWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 188, 78, 184),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.purple,
                ),
                child: const Text(
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
      ),
    );
  }
}
