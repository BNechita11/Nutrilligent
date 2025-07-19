import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nutrilligent/screens/personalized_app_screen.dart';

class CustomizingScreen extends StatefulWidget {
  const CustomizingScreen({super.key});

  @override
  State<CustomizingScreen> createState() => _CustomizingScreenState();
}

class _CustomizingScreenState extends State<CustomizingScreen> {
  @override
  void initState() {
    super.initState();
    _startCustomization();
  }

  Future<void> _startCustomization() async {
    await Future.delayed(Duration(seconds: 3));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PersonalizedPlanScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Customizing the app for you...",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            Lottie.asset(
              'assets/animations/app_loading.json',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}