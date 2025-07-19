import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:logger/logger.dart';
import 'package:nutrilligent/screens/dashboard_screen.dart';

class PersonalizedPlanScreen extends StatefulWidget {
  const PersonalizedPlanScreen({super.key});

  @override
  State<PersonalizedPlanScreen> createState() => _PersonalizedPlanScreenState();
}

class _PersonalizedPlanScreenState extends State<PersonalizedPlanScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  double currentWeight = 0;
  double targetWeight = 0;
  double calorieBudget = 0;
  String targetDate = "";
  int age = 0;
  double height = 0;
  String gender = "unknown";
  String activityLevel = "moderate";
  int estimatedWeeks = 0;
  bool isLoading = true;

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
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          currentWeight = (userDoc["weight"] ?? 0).toDouble();
          targetWeight = double.tryParse(
                  userDoc["targetWeight"].toString().replaceAll(" kg", "")) ??
              0;
          height = (userDoc["height"] ?? 0).toDouble();
          gender = userDoc["gender"] ?? "unknown";
          String birthDate = userDoc["birthDate"] ?? "Unknown date";
          activityLevel = userDoc["activityLevel"] ?? "moderate";

          age = _calculateAge(birthDate);
          calorieBudget = _calculateCalorieBudget();
          estimatedWeeks = _calculateEstimatedWeeks();

          isLoading = false;
        });

        await _firestore.collection("users").doc(user.uid).update({
          "calorieBudget": calorieBudget.toStringAsFixed(0),
          "estimatedWeeks": estimatedWeeks,
        }).then((_) {
          logger.i(" Calorie Budget și Estimated Weeks saved in Firestore.");
        }).catchError((e) {
          logger.e(" Error saving Calorie Budget", error: e);
        });
      }
    } catch (e) {
      logger.e(" Error retrieving user data", error: e);
      setState(() {
        isLoading = false;
      });
    }
  }

  int _calculateAge(String birthDate) {
    try {
      List<String> parts = birthDate.split('-');
      int day = int.parse(parts[0]);
      int month = _monthNames.indexOf(parts[1]) + 1;
      int year = int.parse(parts[2]);
      DateTime dob = DateTime(year, month, day);
      DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      logger.e(" Error calculating age: ${e.toString()}");
      return 0;
    }
  }

  double _calculateBMR() {
    if (gender == "male") {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double _getActivityMultiplier() {
    switch (activityLevel) {
      case "sedentary":
        return 1.2;
      case "light":
        return 1.375;
      case "moderate":
        return 1.55;
      case "active":
        return 1.725;
      default:
        return 1.55;
    }
  }

  double _calculateCalorieBudget() {
    double bmr = _calculateBMR();
    double tdee = bmr * _getActivityMultiplier();
    double deficit = 500;
    double budget = (tdee - deficit).clamp(1200, 2500);
    logger.i("DEBUG: BMR: $bmr, TDEE: $tdee, Calorie Budget: $budget");
    return budget;
  }

  int _calculateEstimatedWeeks() {
    double weightChange = (targetWeight - currentWeight).abs();
    double weeklyRate = 0.5;

    logger.i("DEBUG: Total Weight Change: $weightChange");

    if (weightChange == 0) return 0;

    return (weightChange / weeklyRate).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Your Personalized Plan"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Your plan is ready!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Daily Food Calorie Budget",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    calorieBudget.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    currentWeight < targetWeight
                        ? "Estimated time to gain weight: $estimatedWeeks weeks"
                        : "Estimated time to lose weight: $estimatedWeeks weeks",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  Lottie.asset(
                    'assets/animations/weight_plan.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(user.uid)
                            .set({
                          'onboardingCompleted': true,
                        }, SetOptions(merge: true));
                      }

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DashboardScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 188, 78, 184),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Finish",
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
