import 'package:flutter/material.dart';
import 'package:student_portal/utils/fetchCourse.dart';
import 'package:student_portal/utils/fetchSem.dart';
import 'package:shimmer/shimmer.dart';

class Courses extends StatefulWidget {
  final String accessToken;
  const Courses({super.key, required this.accessToken});

  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<Courses> {
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
              "Registered Courses",
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
        child: _buildCourseCard(staticCourses[index]),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final courseCode = course['customCourseId'] ?? "N/A";
    final courseName = course['courseTitle'] ?? "Not Available";
    final instructorName = course['employeeName'] ?? "TBA";
    final credits = course['totalCredit'] ?? "0";
    final section = course['sectionName'] ?? 'N.A';

    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
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
