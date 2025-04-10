import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:student_portal/pages/Routes/Clearance.dart';
import 'package:student_portal/pages/Routes/Courses.dart';
import 'package:student_portal/pages/Routes/Mid_Quiz.dart';
import 'package:student_portal/pages/Routes/Other.dart';
import 'package:student_portal/utils/spinner.dart';
import '../../widget/Navbar.dart';
import '../Routes/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login/login.dart'; // Make sure to import your Login screen

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? accessToken;
  String? name;
  String? commaSeparatedRoles;
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getData();
  }

  Future<void> _getData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final userName = prefs.getString('name');
    final roles = prefs.getString('commaSeparatedRoles');

    if (token == null) {
      _redirectToLogin();
      return;
    }

    if (mounted) {
      setState(() {
        accessToken = token;
        name = userName;
        commaSeparatedRoles = roles;
        _checkingAuth = false;
      });
    }
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Login()));
      }
    });
  }

  int _currentIndex = 0;
  final PageController _pageController = PageController();

  List<Widget> get _pages {
    if (accessToken != null) {
      return [
        Dashboard(accessToken: accessToken!),
        Clearance(accessToken: accessToken!),
        Courses(accessToken: accessToken!),
        MidQuiz(accessToken: accessToken!),
        const Other(),
      ];
    } else {
      return [const Spinner()];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(body: Spinner());
    }

    return Scaffold(
      appBar: Navbar(name: name ?? 'Guest'),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _handleNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: const Color.fromRGBO(24, 24, 27, .9),
          unselectedItemColor: Colors.grey[600],
          items: _navItems,
        ),
      ),
    );
  }

  void _handleNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  List<BottomNavigationBarItem> get _navItems => [
        BottomNavigationBarItem(
          icon: _AnimatedNavIcon(
            active: _currentIndex == 0,
            icon: Iconsax.home_2,
            inactiveIcon: Iconsax.home_2_copy,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: _AnimatedNavIcon(
            active: _currentIndex == 1,
            icon: Iconsax.note_1,
            inactiveIcon: Iconsax.note_1_copy,
          ),
          label: 'Clearance',
        ),
        BottomNavigationBarItem(
          icon: _AnimatedNavIcon(
            active: _currentIndex == 2,
            icon: Iconsax.book_1,
            inactiveIcon: Iconsax.book_1_copy,
          ),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: _AnimatedNavIcon(
            active: _currentIndex == 3,
            icon: Iconsax.document,
            inactiveIcon: Iconsax.document_copy,
          ),
          label: 'Exams',
        ),
        BottomNavigationBarItem(
          icon: _AnimatedNavIcon(
            active: _currentIndex == 4,
            icon: Iconsax.more,
            inactiveIcon: Iconsax.more_copy,
          ),
          label: 'More',
        ),
      ];
}

class _AnimatedNavIcon extends StatelessWidget {
  final bool active;
  final IconData icon;
  final IconData inactiveIcon;

  const _AnimatedNavIcon({
    required this.active,
    required this.icon,
    required this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: child,
          ),
          child: active
              ? Icon(icon, key: const ValueKey('active'))
              : Icon(inactiveIcon, key: const ValueKey('inactive')),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 6 : 0,
          height: active ? 6 : 0,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(24, 24, 27, .9),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
