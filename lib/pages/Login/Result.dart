import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:student_portal/widget/loadingDuck.dart';
import 'package:student_portal/utils/fetchFinalResult.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ResultDisplay.dart';

class ResultTab extends StatefulWidget {
  const ResultTab({super.key});

  @override
  _ResultTabState createState() => _ResultTabState();
}

class _ResultTabState extends State<ResultTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();

  String? _selectedYear;
  String? _selectedSemester;
  bool _isSubmitting = false;

  // Generate years from current year (2025) down to 2018
  final List<String> _years =
      List.generate(8, (index) => (2025 - index).toString());

  // Semesters without Winter
  final List<String> _semesters = ['Spring', 'Summer', 'Fall'];

  // Map semesters to their numeric codes
  final Map<String, int> _semesterCodes = {
    'Spring': 1,
    'Summer': 2,
    'Fall': 3,
  };

  // To handle API call cancellation
  bool _isCancelled = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _isCancelled = false;
      });

      // Get the last two digits of the year and the semester code
      final yearCode = int.parse(_selectedYear!) % 100;
      final semesterCode = _semesterCodes[_selectedSemester!];
      final semesterId = '$yearCode$semesterCode';
      final studentId = _idController.text.trim();

      try {
        // Make the actual API call using fetchFinalResult
        final result = await fetchFinalResult(semesterId, studentId);

        // Check if the operation was cancelled
        if (_isCancelled) {
          return;
        }

        if (mounted) {
          setState(() => _isSubmitting = false);

          if (result != null) {
            // Navigate to ResultDisplay page with the result data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultDisplay(
                  semesterId: semesterId,
                  studentId: studentId,
                  resultData: result, // Pass the already fetched data
                ),
              ),
            );
          } else {
            // Show error if no results found
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Iconsax.warning_2, color: Colors.white),
                    SizedBox(width: 8),
                    Text("No results found for this ID and semester"),
                  ],
                ),
                backgroundColor: Colors.red[400],
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }
        }
      } catch (e) {
        // Handle any errors that might occur
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $e'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _cancelSubmission() {
    setState(() {
      _isCancelled = true;
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.close_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text("Request cancelled"),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
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
              child: _isSubmitting ? _buildLoadingView() : _buildFormView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Duck loading animation
          const Loading(),

          const SizedBox(height: 24),

          Text(
            "Fetching Results...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 32),

          // Cancel button
          ElevatedButton.icon(
            onPressed: _cancelSubmission,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Iconsax.close_circle),
            label: const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 380),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Iconsax.document_text,
                        color: Colors.black.withOpacity(0.8),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Result Lookup",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Enter your details to view your results",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),
                Divider(color: Colors.black.withOpacity(0.1), height: 1),
                const SizedBox(height: 36),

                // Year dropdown
                _buildDropdownField(
                  label: 'Select Year',
                  icon: Iconsax.calendar,
                  value: _selectedYear,
                  items: _years,
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                  scrollable: true,
                ),
                const SizedBox(height: 20),

                // Semester dropdown
                _buildDropdownField(
                  label: 'Select Semester',
                  icon: Iconsax.book_1,
                  value: _selectedSemester,
                  items: _semesters,
                  onChanged: (value) {
                    setState(() {
                      _selectedSemester = value;
                    });
                  },
                  scrollable: false,
                ),
                const SizedBox(height: 20),

                // Student ID field
                _buildInputField(
                  controller: _idController,
                  label: "Enter your ID",
                  icon: Iconsax.user,
                  tooltip: "Enter your student ID number",
                ),
                const SizedBox(height: 36),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.search_normal, size: 22),
                        const SizedBox(width: 12),
                        const Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required bool scrollable,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.6)),
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
        value: value,
        isExpanded: true,
        icon: Icon(Iconsax.arrow_down_1, color: Colors.black.withOpacity(0.6)),
        dropdownColor: Colors.white,
        menuMaxHeight: scrollable ? 200 : null,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item,
                style: TextStyle(color: Colors.black.withOpacity(0.8))),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select an option' : null,
        style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 16),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.6)),
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
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter your ID' : null,
        cursorColor: Colors.black,
      ),
    );
  }
}
