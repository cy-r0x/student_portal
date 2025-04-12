import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_portal/common/FColors.dart';
import './pages/Login/login.dart';
import './pages/Home/home.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable high refresh rate on Android
  try {
    await FlutterDisplayMode.setHighRefreshRate();
    // Optional: Print available display modes
    final List<DisplayMode> supportedModes = await FlutterDisplayMode.supported;
    final DisplayMode activeMode = await FlutterDisplayMode.active;
    
    print('Supported display modes:');
    supportedModes.forEach(print);
    print('Active display mode: $activeMode');
  } on PlatformException catch (e) {
  }
  
  // Disable unnecessary animations and effects that might cause rendering issues
  // debugDisableShadows = true;
  
  runApp(MyApp());
}

class SharedPrefService {
  static SharedPreferences? _prefs;

  static const String _keyAccessToken = "accessToken";
  static const String _keyUsername = "username";
  static const String _keyName = "name";

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save login data
  static Future<void> saveLoginData({
    required String accessToken,
    required String username,
    required String name,
  }) async {
    if (_prefs == null) await init();
    await _prefs!.setString(_keyAccessToken, accessToken);
    await _prefs!.setString(_keyUsername, username);
    await _prefs!.setString(_keyName, name);
  }

  // Getters
  static String? get accessToken => _prefs?.getString(_keyAccessToken);
  static String? get username => _prefs?.getString(_keyUsername);
  static String? get name => _prefs?.getString(_keyName);

  // Check if user is logged in
  static bool isLoggedIn() {
    return _prefs?.getString(_keyAccessToken) != null;
  }

  // Logout and clear stored data
  static Future<void> logout() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _initializeApp() async {
    await SharedPrefService.init();
    return SharedPrefService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: FColors.primary,
        // Removed invalid imageTheme parameter
        // Simplify page transitions to avoid rendering issues
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: FutureBuilder<bool>(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data == true ? Home() : Login();
        },
      ),
    );
  }
}
