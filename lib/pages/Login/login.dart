import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
                      const SizedBox(height: 20),
                      _buildFooterLinks(),
                    ],
                  ),
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
        Image.asset("assets/images/logo.png", width: 120),
        const SizedBox(height: 24),
        Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.grey[800],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please sign in to continue",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
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
          const SizedBox(height: 16),
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
                color: Colors.grey[600],
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Sign In",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {/* Add forgot password logic */},
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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

      // Call the login API
      final response = await _loginApi(username, password);

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

  Future<Map<String, dynamic>?> _loginApi(
      String username, String password) async {
    final url = Uri.parse('http://203.190.10.22:8006/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set the correct Content-Type
        },
        body: json.encode({
          'username': username,
          'password': password,
          'grecaptcha': '',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Parse the response body
      } else {
        // Handle API error
        return null;
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error: $e');
      return null;
    }
  }
}
