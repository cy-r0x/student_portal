import 'package:flutter/material.dart';
import 'package:student_portal/utils/fetchCourse.dart';
import 'package:student_portal/utils/fetchResult.dart';
import 'package:student_portal/utils/fetchSem.dart';
import 'package:shimmer/shimmer.dart';

class MidQuiz extends StatefulWidget {
  final String accessToken;
  const MidQuiz({super.key, required this.accessToken});

  @override
  _MidQuiz createState() => _MidQuiz();
}

class _MidQuiz extends State<MidQuiz> {
  List<dynamic> semesters = [];
  List<Map<String, dynamic>> staticCourses = [];
  bool isRefreshing = false;

  String? selectedSemesterId;
  bool isLoading = false;

  Future<void> _getSem() async {
    final fetchedData = await fetchSem(widget.accessToken);
    if (fetchedData != null) {
      if (mounted) {
        setState(() {
          semesters = fetchedData;
        });
      }
    }
  }

  Future<void> _getCourse() async {
    if (selectedSemesterId != null) {
      final fetchedCourse =
          await fetchCourse(widget.accessToken, selectedSemesterId!);
      if (fetchedCourse != null) {
        setState(() {
          staticCourses = fetchedCourse;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getSem();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchCourses(String semesterId) {
    setState(() {
      selectedSemesterId = semesterId;
      isRefreshing = true; // Set isRefreshing to true while fetching
    });

    _getCourse().then((_) {
      if (mounted) {
        setState(() {
          isRefreshing = false; // Set isRefreshing to false after fetching
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          isRefreshing = false; // Ensure isRefreshing is false even on error
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching courses: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Live Result",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildSemesterDropdown(),
            const SizedBox(height: 20),
            Expanded(
              child: isRefreshing
                  ? _buildShimmerEffect() // Show shimmer effect while refreshing
                  : _buildCourseList(), // Show course list when not refreshing
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Select Semester',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: const Icon(Icons.calendar_today, size: 18),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      value: selectedSemesterId,
      isExpanded: false,
      icon: const Icon(Icons.arrow_drop_down_circle),
      items: semesters.map<DropdownMenuItem<String>>((semester) {
        final displayText =
            "${semester['semesterName']} ${semester['semesterYear']}";
        return DropdownMenuItem<String>(
          value: semester['semesterId'],
          child: Text(displayText),
        );
      }).toList(),
      onChanged: (value) => _fetchCourses(value!),
      menuMaxHeight: 200, // Set a fixed height for the dropdown menu
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseList() {
    if (staticCourses.isEmpty) {
      return Center(
        child: Text("No Data Available"),
      );
    }

    return ListView.separated(
      itemCount: staticCourses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _buildResultCard(staticCourses[index]),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> course) {
    final courseCode = course['customCourseId'] ?? "N/A";
    final courseName = course['courseTitle'] ?? "Not Available";
    final instructorName = course['employeeName'] ?? "TBA";
    final credits = course['totalCredit'] ?? "0";
    final section = course['sectionName'] ?? 'N.A';
    final courseSectionId = course['courseSectionId'] ?? 'N/A';

    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          final data = fetchResult(widget.accessToken, courseSectionId);
          data.then((result) {
            if (result != null) {
              // Show modern popup with result data
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // Calculate the total score if needed
                  final double mid1 = double.tryParse(result['mid1']?.toString() ?? '0') ?? 0;
                  final double mid2 = double.tryParse(result['mid2']?.toString() ?? '0') ?? 0;
                  final double quiz = double.tryParse(result['quiz']?.toString() ?? '0') ?? 0;
                  final double attendance = double.tryParse(result['att']?.toString() ?? '0') ?? 0;
                  
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    backgroundColor: Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.analytics_outlined, 
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      courseName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          Divider(height: 24, thickness: 1),
                          
                          // Results content
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                // Mid section
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Mid Term Exams",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildResultRow('Midterm', result['mid1']?.toString() ?? 'N/A'),                                
                                SizedBox(height: 16),
                                
                                // Quiz section
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Quizzes",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildResultRow('Quiz Total', result['quiz']?.toString() ?? 'N/A'),
                                _buildResultRow('Quiz 1', result['q1']?.toString() ?? 'N/A'),
                                _buildResultRow('Quiz 2', result['q2']?.toString() ?? 'N/A'),
                                _buildResultRow('Quiz 3', result['q3']?.toString() ?? 'N/A'),
                                
                                SizedBox(height: 16),
                                
                                // Attendance section
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Attendance",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Attendance',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Container(
                                      width: 80,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.orange[300]!, Colors.orange[500]!],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${result['att']?.toString() ?? 'N/A'}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              // Show a snackbar for no data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text("No result data available"),
                    ],
                  ),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }).catchError((error) {
            // Show a snackbar for error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Failed to load results"),
                  ],
                ),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    courseCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Chip(
                    backgroundColor: Colors.black,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    label: Text(
                      instructorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    avatar:
                        const Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                courseName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.credit_card,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "$credits Credit",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Section: $section",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

