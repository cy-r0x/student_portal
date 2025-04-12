import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:student_portal/widget/loadingDuck.dart';

class ResultDisplay extends StatefulWidget {
  final String semesterId;
  final String studentId;

  const ResultDisplay({
    Key? key,
    required this.semesterId,
    required this.studentId,
  }) : super(key: key);

  @override
  _ResultDisplayState createState() => _ResultDisplayState();
}

class _ResultDisplayState extends State<ResultDisplay> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<dynamic> _resultData = [];
  
  // Summary data
  double _cgpa = 0.0;
  double _totalCredits = 0.0;
  double _totalGradePoints = 0.0;
  String _semesterName = '';
  int _semesterYear = 0;

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://software.diu.edu.bd:8006/result?grecaptcha=&semesterId=${widget.semesterId}&studentId=${widget.studentId}'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data != null && data.isNotEmpty) {
          // Calculate total credits and grade points
          double totalCredits = 0.0;
          double totalGradePoints = 0.0;
          
          for (var course in data) {
            totalCredits += double.parse(course['totalCredit'].toString());
            totalGradePoints += double.parse(course['totalCredit'].toString()) * 
                               double.parse(course['pointEquivalent'].toString());
          }
          
          setState(() {
            _resultData = data;
            _isLoading = false;
            _cgpa = double.parse(data[0]['cgpa'].toString());
            _totalCredits = totalCredits;
            _totalGradePoints = totalGradePoints;
            _semesterName = data[0]['semesterName'];
            _semesterYear = data[0]['semesterYear'];
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'No results found for this ID and semester.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load results. Error ${response.statusCode}.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester Results', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Loading(),
                  SizedBox(height: 20),
                  Text(
                    'Loading Results...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _hasError
              ? _buildErrorView()
              : _buildResultView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 60,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _fetchResult();
            },
            icon: const Icon(Iconsax.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildCoursesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF343434), Color(0xFF151515)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Student ID",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.studentId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.calendar,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$_semesterName $_semesterYear",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CGPA",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _cgpa.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getGradeColor(_cgpa),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getGradeLetter(_cgpa),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getGradeStatus(_cgpa),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    // Calculate semester GPA
    double semesterGPA = _totalGradePoints / _totalCredits;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Semester Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  "Semester GPA", 
                  semesterGPA.toStringAsFixed(2),
                  Iconsax.chart,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  "Total Credits", 
                  _totalCredits.toStringAsFixed(1),
                  Iconsax.book_1,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  "Courses", 
                  _resultData.length.toString(),
                  Iconsax.document_text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.black87,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "Course Results",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._resultData.map((course) {
            return _buildCourseCard(course);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final double pointEquivalent = double.parse(course['pointEquivalent'].toString());
    final String gradeLetter = course['gradeLetter'];
    final double totalCredit = double.parse(course['totalCredit'].toString());
    final String courseTitle = course['courseTitle'];
    final String courseCode = course['customCourseId'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getGradeColor(pointEquivalent).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Iconsax.book,
                        color: _getGradeColor(pointEquivalent),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseCode,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            courseTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCourseInfoItem("Credit", totalCredit.toString()),
                    _buildCourseInfoItem("Grade", gradeLetter),
                    _buildCourseInfoItem("GPA", pointEquivalent.toString()),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getGradeColor(pointEquivalent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                gradeLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(double gpa) {
    if (gpa >= 3.75) return const Color(0xFF4CAF50); // A, A+
    if (gpa >= 3.50) return const Color(0xFF8BC34A); // A-
    if (gpa >= 3.25) return const Color(0xFFCDDC39); // B+
    if (gpa >= 3.00) return const Color(0xFFFFC107); // B
    if (gpa >= 2.75) return const Color(0xFFFF9800); // B-
    if (gpa >= 2.50) return const Color(0xFFFF5722); // C+
    if (gpa >= 2.25) return const Color(0xFFF44336); // C
    return const Color(0xFF9E9E9E); // Below C
  }

  String _getGradeLetter(double gpa) {
    if (gpa >= 4.00) return "A+";
    if (gpa >= 3.75) return "A";
    if (gpa >= 3.50) return "A-";
    if (gpa >= 3.25) return "B+";
    if (gpa >= 3.00) return "B";
    if (gpa >= 2.75) return "B-";
    if (gpa >= 2.50) return "C+";
    if (gpa >= 2.25) return "C";
    if (gpa >= 2.00) return "D";
    return "F";
  }

  String _getGradeStatus(double gpa) {
    if (gpa >= 3.75) return "Excellent";
    if (gpa >= 3.50) return "Very Good";
    if (gpa >= 3.00) return "Good";
    if (gpa >= 2.50) return "Satisfactory";
    if (gpa >= 2.00) return "Passing";
    return "Failing";
  }
}