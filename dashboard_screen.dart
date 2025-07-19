import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:nutrilligent/widgets/gauge_meter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nutrilligent/widgets/stat_card.dart';
import 'package:nutrilligent/screens/recipe_details_screen.dart';
import 'package:nutrilligent/widgets/recipe_card.dart';
import 'package:nutrilligent/models/recipe_model.dart';
import 'package:nutrilligent/screens/community_screen.dart';
import 'package:nutrilligent/widgets/workout_card.dart';
import 'package:nutrilligent/screens/workout_detail_screen.dart';
import 'package:nutrilligent/models/workout_model.dart';
import 'package:nutrilligent/screens/me_screen.dart';
import 'package:nutrilligent/widgets/quick_actions_popup.dart';
import 'package:nutrilligent/widgets/advice_section.dart';
import '../services/vibe_check_service.dart';
import '../widgets/vibe_check_dialog.dart';
import 'package:provider/provider.dart';
import '../theme/app_themes.dart';
import '../theme/theme_notifier.dart';
import '../models/meditation_model.dart';
import '../widgets/meditation_card.dart';
import 'meditation_details_screen.dart';
import '../services/weekly_stats_service.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/calorie_target_ring.dart';
import '../widgets/week_review_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

extension StringCap on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();
  final VibeCheckService _vibeService = VibeCheckService();

  double? calorieBudget;
  double? caloriesConsumed;
  double? caloriesLeft;
  int steps = 0;
  int waterIntake = 0;
  int snacks = 0;
  int breakfast = 0;
  int lunch = 0;
  int dinner = 0;
  int _selectedIndex = 0;

  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkVibeDialog();
  }

  Future<void> _fetchUserData() async {
    if (_auth.currentUser == null) return;

    final userId = _auth.currentUser!.uid;
    final docId =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    try {
      final userDoc = await _firestore.collection("users").doc(userId).get();
      final statDoc = await _firestore
          .collection("users")
          .doc(userId)
          .collection("dailyStats")
          .doc(docId)
          .get();

      if (userDoc.exists) {
        calorieBudget =
            double.tryParse(userDoc["calorieBudget"]?.toString() ?? "1600") ??
                1600;
      }
      if (statDoc.exists) {
        final data = statDoc.data()!;

        setState(() {
          breakfast = data["breakfast"] ?? 0;
          lunch = data["lunch"] ?? 0;
          dinner = data["dinner"] ?? 0;
          snacks = data["snacks"] ?? 0;
          steps = data["steps"] ?? 0;
          waterIntake = data["water"] ?? 0;
          caloriesConsumed = data["caloriesConsumed"]?.toDouble() ?? 0;
          caloriesLeft = data["caloriesLeft"]?.toDouble() ??
              (calorieBudget! - caloriesConsumed!);
        });
      } else {
        setState(() {
          breakfast = lunch = dinner = snacks = steps = waterIntake = 0;
          caloriesConsumed = 0;
          caloriesLeft = calorieBudget!;
        });
      }

      logger.i("Dashboard data loaded for $docId");
    } catch (e) {
      logger.e(" Error loading dashboard data", error: e);
    }
  }

  Future<void> saveDailyStatsForDay(DateTime day) async {
    final userId = _auth.currentUser!.uid;
    final docId =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('dailyStats')
        .doc(docId)
        .set({
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'snacks': snacks,
      'steps': steps,
      'water': waterIntake,
      'caloriesConsumed': caloriesConsumed,
      'caloriesLeft': caloriesLeft,
      'createdAt': Timestamp.fromDate(day),
    });
  }

  Future<void> _updateWaterIntake(BuildContext context) async {
    TextEditingController waterController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title:
              Text("Enter water intake", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: waterController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Number of cups",
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                int? newWater = int.tryParse(waterController.text);
                if (newWater == null) return;

                final userId = _auth.currentUser!.uid;
                final dateId =
                    "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

                try {
                  await _firestore
                      .collection("users")
                      .doc(userId)
                      .collection("dailyStats")
                      .doc(dateId)
                      .set({
                    "water": newWater,
                    "createdAt": Timestamp.now(),
                  }, SetOptions(merge: true));

                  if (!mounted) return;

                  setState(() {
                    waterIntake = newWater;
                  });

                  await saveDailyStatsForDay(selectedDay);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  logger.e("Error updating water intake", error: e);
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateSteps(BuildContext context) async {
    TextEditingController stepsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title:
              Text("Enter steps count", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: stepsController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Number of steps",
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                int? newSteps = int.tryParse(stepsController.text);
                if (newSteps == null || _auth.currentUser == null) return;

                final uid = _auth.currentUser!.uid;
                final formattedDay =
                    "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                final caloriesBurned = newSteps * 0.04;

                try {
                  await _firestore
                      .collection("users")
                      .doc(uid)
                      .collection("dailyStats")
                      .doc(formattedDay)
                      .set({
                    'steps': newSteps,
                    'caloriesConsumed': (caloriesConsumed! - caloriesBurned)
                        .clamp(0, calorieBudget!),
                    'createdAt': Timestamp.now(),
                  }, SetOptions(merge: true));

                  setState(() {
                    steps = newSteps;
                    caloriesConsumed = (caloriesConsumed! - caloriesBurned)
                        .clamp(0, calorieBudget!);
                    caloriesLeft = calorieBudget! - caloriesConsumed!;
                  });
                } catch (e) {
                  logger.e("Error updating steps", error: e);
                }

                if (context.mounted) {
                  await saveDailyStatsForDay(selectedDay);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateSnacks(BuildContext context) async {
    TextEditingController snacksController = TextEditingController();
    String userId = _auth.currentUser!.uid;
    String docId =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Enter snack calories",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: snacksController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Calories",
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                int? newSnackCalories = int.tryParse(snacksController.text);
                if (newSnackCalories != null) {
                  final dailyRef = _firestore
                      .collection("users")
                      .doc(userId)
                      .collection("dailyStats")
                      .doc(docId);
                  final snapshot = await dailyRef.get();
                  int previousSnacks =
                      snapshot.exists ? (snapshot.data()?["snacks"] ?? 0) : 0;
                  double existingCalories = snapshot.exists
                      ? (snapshot.data()?["caloriesConsumed"] ?? 0.0)
                      : 0.0;

                  int updatedSnacks = previousSnacks + newSnackCalories;
                  double newCaloriesConsumed =
                      existingCalories + newSnackCalories;
                  double newCaloriesLeft =
                      (calorieBudget ?? 1600) - newCaloriesConsumed;

                  await dailyRef.set({
                    "snacks": updatedSnacks,
                    "caloriesConsumed": newCaloriesConsumed,
                    "caloriesLeft": newCaloriesLeft,
                    "createdAt": Timestamp.now(),
                  }, SetOptions(merge: true));

                  setState(() {
                    snacks = updatedSnacks;
                    caloriesConsumed = newCaloriesConsumed;
                    caloriesLeft = newCaloriesLeft;
                  });

                  await saveDailyStatsForDay(selectedDay);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBreakfast(BuildContext context) async {
    TextEditingController breakfastController = TextEditingController();
    String userId = _auth.currentUser!.uid;
    String docId =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Enter breakfast calories",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: breakfastController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Calories",
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                int? newCalories = int.tryParse(breakfastController.text);
                if (newCalories != null) {
                  final dailyRef = _firestore
                      .collection("users")
                      .doc(userId)
                      .collection("dailyStats")
                      .doc(docId);
                  final snapshot = await dailyRef.get();
                  int previous = snapshot.exists
                      ? (snapshot.data()?["breakfast"] ?? 0)
                      : 0;
                  double existingCalories = snapshot.exists
                      ? (snapshot.data()?["caloriesConsumed"] ?? 0.0)
                      : 0.0;

                  int updated = previous + newCalories;
                  double newCaloriesConsumed = existingCalories + newCalories;
                  double newCaloriesLeft =
                      (calorieBudget ?? 1600) - newCaloriesConsumed;

                  await dailyRef.set({
                    "breakfast": updated,
                    "caloriesConsumed": newCaloriesConsumed,
                    "caloriesLeft": newCaloriesLeft,
                    "createdAt": Timestamp.now(),
                  }, SetOptions(merge: true));

                  setState(() {
                    breakfast = updated;
                    caloriesConsumed = newCaloriesConsumed;
                    caloriesLeft = newCaloriesLeft;
                  });

                  await saveDailyStatsForDay(selectedDay);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDinner(BuildContext context) async {
    TextEditingController dinnerController = TextEditingController();
    String userId = _auth.currentUser!.uid;
    String docId =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Enter dinner calories",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: dinnerController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Calories",
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                int? newCalories = int.tryParse(dinnerController.text);
                if (newCalories != null) {
                  final dailyRef = _firestore
                      .collection("users")
                      .doc(userId)
                      .collection("dailyStats")
                      .doc(docId);
                  final snapshot = await dailyRef.get();
                  int previous =
                      snapshot.exists ? (snapshot.data()?["dinner"] ?? 0) : 0;
                  double existingCalories = snapshot.exists
                      ? (snapshot.data()?["caloriesConsumed"] ?? 0.0)
                      : 0.0;

                  int updated = previous + newCalories;
                  double newCaloriesConsumed = existingCalories + newCalories;
                  double newCaloriesLeft =
                      (calorieBudget ?? 1600) - newCaloriesConsumed;

                  await dailyRef.set({
                    "dinner": updated,
                    "caloriesConsumed": newCaloriesConsumed,
                    "caloriesLeft": newCaloriesLeft,
                    "createdAt": Timestamp.now(),
                  }, SetOptions(merge: true));

                  setState(() {
                    dinner = updated;
                    caloriesConsumed = newCaloriesConsumed;
                    caloriesLeft = newCaloriesLeft;
                  });

                  await saveDailyStatsForDay(selectedDay);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateLunch(BuildContext context) async {
    TextEditingController lunchController = TextEditingController();
    String userId = _auth.currentUser!.uid;
    String docId =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Enter lunch calories",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: lunchController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Calories",
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                int? newCalories = int.tryParse(lunchController.text);
                if (newCalories != null) {
                  final dailyRef = _firestore
                      .collection("users")
                      .doc(userId)
                      .collection("dailyStats")
                      .doc(docId);
                  final snapshot = await dailyRef.get();
                  int previous =
                      snapshot.exists ? (snapshot.data()?["lunch"] ?? 0) : 0;
                  double existingCalories = snapshot.exists
                      ? (snapshot.data()?["caloriesConsumed"] ?? 0.0)
                      : 0.0;

                  int updated = previous + newCalories;
                  double newCaloriesConsumed = existingCalories + newCalories;
                  double newCaloriesLeft =
                      (calorieBudget ?? 1600) - newCaloriesConsumed;

                  await dailyRef.set({
                    "lunch": updated,
                    "caloriesConsumed": newCaloriesConsumed,
                    "caloriesLeft": newCaloriesLeft,
                    "createdAt": Timestamp.now(),
                  }, SetOptions(merge: true));

                  setState(() {
                    lunch = updated;
                    caloriesConsumed = newCaloriesConsumed;
                    caloriesLeft = newCaloriesLeft;
                  });

                  await saveDailyStatsForDay(selectedDay);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<String> _fetchUserActivityLevel() async {
    if (_auth.currentUser == null) return "sedentary";

    String userId = _auth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(userId).get();

    if (userDoc.exists && userDoc["activityLevel"] != null) {
      return userDoc["activityLevel"];
    } else {
      return "sedentary"; //default
    }
  }

  Future<List<Recipe>> _fetchRecipes() async {
    try {
      final snapshot = await _firestore.collection('recipes').get();

      if (snapshot.docs.isEmpty) {
        logger.w("📭 No recipes found in Firestore.");
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        logger.i("🍽️ Found recipe: ${data['title']}");
        return Recipe.fromMap(data);
      }).toList();
    } catch (e, stack) {
      logger.e(" Error fetching recipes", error: e, stackTrace: stack);
      return [];
    }
  }

  Future<List<Workout>> _fetchWorkouts() async {
    try {
      final snapshot = await _firestore.collection('workouts').get();
      return snapshot.docs.map((doc) => Workout.fromMap(doc.data())).toList();
    } catch (e) {
      logger.e(" Error fetching workouts", error: e);
      return [];
    }
  }

  Future<List<Meditation>> _fetchMeditations() async {
    final snapshot = await _firestore.collection('meditations').get();
    return snapshot.docs
        .map((d) => Meditation.fromMap(d.id, d.data()))
        .toList();
  }

  Future<List<Map<String, String>>> _fetchPersonalizedAdvice() async {
    String activityLevel = await _fetchUserActivityLevel();
    logger.i("User activity level: $activityLevel");

    QuerySnapshot snapshot = await _firestore
        .collection("advice")
        .where("category", isEqualTo: activityLevel)
        .get();

    logger.i("Fetched advice count: ${snapshot.docs.length}");

    return snapshot.docs
        .map((doc) => {
              "title": doc["title"] as String,
              "content": doc["content"] as String
            })
        .toList();
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CommunityScreen()),
      );
    } else if (index == 2) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeScreen(
              userId: user.uid,
              isEditable: true,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _openCalendar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 35, 35, 35),
          content: SizedBox(
            height: 440,
            width: 350,
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: selectedDay,
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                setState(() {
                  selectedDay = selectDay;
                });
                _fetchUserData();

                Navigator.pop(context);
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 188, 78, 184),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.purple.shade900,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
                outsideDaysVisible: false,
                cellMargin: EdgeInsets.symmetric(vertical: 6),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 188, 78, 184),
                  borderRadius: BorderRadius.circular(10),
                ),
                headerMargin: EdgeInsets.only(bottom: 16),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.redAccent),
              ),
              daysOfWeekHeight: 35,
            ),
          ),
        );
      },
    );
  }

  void _checkVibeDialog() async {
    final shouldShow = await _vibeService.shouldShowVibeCheck();

    if (shouldShow && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => VibeCheckDialog(
            onConfirm: (mood) async {
              try {
                await _vibeService.recordVibeCheck(mood);
              } catch (e) {
                debugPrint(" Failed to record vibe: $e");
              }
            },
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Today",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _openCalendar,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => Consumer<ThemeNotifier>(
                  builder: (ctx, theme, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AppTheme.values.map((t) {
                      return RadioListTile<AppTheme>(
                        title: Text(t.toString().split('.').last.capitalize()),
                        value: t,
                        groupValue: theme.current,
                        onChanged: (v) {
                          theme.setTheme(v!);
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Calorie Budget Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "Calorie Budget",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    calorieBudget != null
                        ? calorieBudget!.toStringAsFixed(0)
                        : "...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  GaugeMeter(
                    calorieBudget: calorieBudget ?? 1600,
                    caloriesConsumed: caloriesConsumed ?? 0,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Left",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    caloriesLeft != null
                        ? caloriesLeft!.toStringAsFixed(0)
                        : "...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Meal Stats Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _updateBreakfast(context),
                  child: StatCard(
                    title: "Breakfast",
                    value: "$breakfast",
                    unit: "cal",
                  ),
                ),
                GestureDetector(
                  onTap: () => _updateLunch(context),
                  child: StatCard(
                    title: "Lunch",
                    value: "$lunch",
                    unit: "cal",
                  ),
                ),
                GestureDetector(
                  onTap: () => _updateDinner(context),
                  child: StatCard(
                    title: "Dinner",
                    value: "$dinner",
                    unit: "cal",
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Additional Stats Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _updateSnacks(context),
                  child: StatCard(
                    title: "Snacks",
                    value: "$snacks",
                    unit: "cal",
                  ),
                ),
                GestureDetector(
                  onTap: () => _updateSteps(context),
                  child: StatCard(
                    title: "Steps",
                    value: "$steps",
                    unit: "steps",
                  ),
                ),
                GestureDetector(
                  onTap: () => _updateWaterIntake(context),
                  child: StatCard(
                    title: "Water",
                    value: "$waterIntake",
                    unit: "cups",
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Advice Section
            AdviceSection(fetchAdvice: _fetchPersonalizedAdvice),
            SizedBox(height: 20),
            FutureBuilder(
              future: WeeklyStatsService().fetchLast7DaysStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.dailyStats.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      "No weekly data available.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final stats = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 200,
                      child: WeeklyBarChart(stats: stats.dailyStats),
                    ),
                    SizedBox(height: 20),
                    CalorieTargetRing(
                      daysMetTarget:
                          stats.daysMeetingTarget(calorieBudget ?? 1600),
                    ),
                    SizedBox(height: 20),
                    WeekReviewCard(stats: stats),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),

            // Recommended Recipes Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recommended Recipes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),
            FutureBuilder<List<Recipe>>(
              future: _fetchRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      "No recipes available yet.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final recipes = snapshot.data!;
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            // Recommended Workouts Section
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recommended Workouts",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),
            FutureBuilder<List<Workout>>(
              future: _fetchWorkouts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      "No workouts available yet.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final workouts = snapshot.data!;
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return WorkoutCard(
                        workout: workout,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkoutDetailScreen(workout: workout),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Recommended Meditations Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recommended Meditations",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Meditation>>(
              future: _fetchMeditations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      "No meditations available yet.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                final meditations = snapshot.data!;
                return SizedBox(
                  height: 180, // adjust as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: meditations.length,
                    itemBuilder: (context, i) {
                      final m = meditations[i];
                      return MeditationCard(
                        meditation: m,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MeditationDetailScreen(meditation: m),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const QuickActionsPopup(),
          );
        },
        child: const Icon(Icons.add),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Me",
          ),
        ],
      ),
    );
  }
}
