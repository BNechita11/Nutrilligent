import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'body_progress_gallery_screen.dart';
import 'journal_screen.dart';
import 'edit_profile_screen.dart';
import 'chat_with_nutribot_screen.dart';


class MeScreen extends StatefulWidget {
  final String userId;
  final bool isEditable;

  const MeScreen({
    super.key,
    required this.userId,
    this.isEditable = false,
  });

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  AppUser? user;
  bool isLoading = false;
  bool hasError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _loadUser();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final profile = await _userService.getUserProfile(widget.userId);
      if (mounted) {
        setState(() {
          user = profile;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  void _navigateToEditScreen(BuildContext context) {
    if (user == null) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditProfileScreen(user: user!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ).then((_) => _loadUser());
  }

  void _navigateToProgressGallery() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BodyProgressGalleryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToJournal() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const JournalScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
  
  void _navigateToNutriBot() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ChatWithNutriBotScreen()),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0x4D000000),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 22),
            ),
            onPressed: _loadUser,
          ),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: const Color(0xFFBB86FC),
        color: Colors.white,
        onRefresh: _loadUser,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isEditable
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFBB86FC),
              onPressed: () => _navigateToEditScreen(context),
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildProfileHeader() {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3700B3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFBB86FC),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4D000000),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.white70)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user?.email != null)
                      Text(
                        user!.email,
                        style: TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && user == null) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFBB86FC)),
          ),
        ),
      );
    }

    if (hasError) {
      return SliverFillRemaining(
        child: _buildError(),
      );
    }

    if (user == null) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            "No profile found",
            style: TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSection("Personal Info", [
          _buildRow(Icons.person_outline, "Name", user!.name),
          _buildRow(Icons.email_outlined, "Email", user!.email),
          _buildRow(Icons.transgender, "Gender", user!.gender),
          _buildRow(Icons.cake_outlined, "Age", "${user!.age} y.o"),
        ]),
        const SizedBox(height: 16),
        _buildSection("Body Stats", [
          _buildRow(Icons.height, "Height", "${user!.height} cm"),
          _buildRow(Icons.monitor_weight_outlined, "Weight",
              "${user!.weight} ${user!.weightUnit}"),
          _buildRow(Icons.flag_outlined, "Target Weight", user!.targetWeight),
          _buildInteractiveRow(Icons.photo_library_outlined, "Progress Photos",
              "${user!.bodyProgressPhotos.length}", _navigateToProgressGallery),
        ]),
        const SizedBox(height: 16),
        _buildSection("Activity", [
          _buildRow(
              Icons.directions_run, "Activity Level", user!.activityLevel),
          _buildRow(Icons.local_fire_department_outlined,
              "Daily Calorie Budget", user!.calorieBudget),
          _buildRow(Icons.calendar_today_outlined, "Estimated Weeks",
              "${user!.estimatedWeeks}"),
          _buildRow(
              Icons.directions_walk_outlined, "Steps Today", "${user!.steps}"),
          _buildInteractiveRow(
              Icons.book_outlined, "Journal", "Open", _navigateToJournal),
          _buildInteractiveRow(Icons.smart_toy_outlined, "Chat with NutriBot",
              "Ask", _navigateToNutriBot),
        ]),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFCF6679), size: 48),
          const SizedBox(height: 16),
          const Text(
            "Failed to load profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please check your connection and try again",
            style: TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBB86FC),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _loadUser,
            child: const Text(
              "Try Again",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFBB86FC),
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFBB86FC), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xB3FFFFFF),
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value ?? 'N/A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveRow(
      IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFBB86FC), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontSize: 15,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Color(0xB3FFFFFF), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
