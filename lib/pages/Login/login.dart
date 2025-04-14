import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Home/home.dart';
import 'Result.dart';
import '../../utils/fetchLogin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Student Portal',
            style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Result'),
          ],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLoginView(),
                const ResultTab(),
              ],
            ),
          ),
          _buildFooterVersion(),
        ],
      ),
    );
  }

  Widget _buildLoginView() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 36),
                    Divider(color: Colors.black.withOpacity(0.1), height: 1),
                    const SizedBox(height: 36),
                    _buildLoginForm(),
                    const SizedBox(height: 36),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    _buildPasswordLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset("assets/images/logo.png", width: 80),
        ),
        const SizedBox(height: 24),
        Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please sign in to continue",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return AutofillGroup(
      child: Column(
        children: [
          _buildInputField(
            controller: _idController,
            label: "Student ID",
            icon: Iconsax.user,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
            validator: (value) =>
                value?.isEmpty ?? true ? 'ID is required' : null,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _passwordController,
            label: "Password",
            icon: Iconsax.lock,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                color: Colors.black.withOpacity(0.6),
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Password is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    List<String>? autofillHints,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      validator: validator,
      style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.6)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.black.withOpacity(0.2), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.black.withOpacity(0.2), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.black.withOpacity(0.5), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.02),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      cursorColor: Colors.black,
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.login, size: 22),
                  const SizedBox(width: 12),
                  const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPasswordLink() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: Colors.black.withOpacity(0.5),
      ),
      child: const Text(
        "Forgot Password?",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildFooterVersion() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Version 1.0.0b | ",
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          Text(
            "Developed by ",
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://www.facebook.com/cyr0xx');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
            child: Text(
              "cyr0x",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // Prepare the payload
      final String username = _idController.text.trim();
      final String password = _passwordController.text.trim();

      // Validate input
      if (username.isEmpty || password.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username and password cannot be empty."),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Call the login API using the utility function
      final response = await fetchLogin(username, password);

      if (response != null && response['message'] == 'success') {
        // Store accessToken in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', response['accessToken'] ?? '');
        await prefs.setString('userName', response['userName'] ?? '');
        await prefs.setString(
            'commaSeparatedRoles', response['commaSeparatedRoles'] ?? '');
        await prefs.setString('name', response['name'] ?? '');

        // Navigate to Home screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        // Handle login failure
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response?['error'] ?? 'Login failed. Please try again.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      // Ensure loading state is reset
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
