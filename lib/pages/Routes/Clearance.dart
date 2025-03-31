import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package
import '../../utils/fetchClearance.dart'; // Import the fetchClearance function

class Clearance extends StatefulWidget {
  const Clearance({
    super.key,
    required this.accessToken,
  });

  final String accessToken;

  @override
  State<Clearance> createState() => _ClearanceState();
}

class _ClearanceState extends State<Clearance> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    setState(() => isLoading = true);

    try {
      // Load cached data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cachedClearanceData');

      if (cachedData != null) {
        // Parse cached data and update the state
        final List<dynamic> parsedData = json.decode(cachedData);
        setState(() {
          data = List<Map<String, dynamic>>.from(
              parsedData.map((item) => Map<String, dynamic>.from(item)));
        });
      }

      // Fetch fresh data from the API
      await _fetchClearance();
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred while loading data: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _fetchClearance({bool refresh = false}) async {
    if (!refresh && data.isNotEmpty) {
      // If data is already loaded and not refreshing, skip fetching
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final fetchedData = await getClearance(widget.accessToken);
      if (fetchedData != null) {
        if (mounted) {
          setState(() {
            data = List<Map<String, dynamic>>.from(
                fetchedData.map((item) => Map<String, dynamic>.from(item)));
          });

          // Cache the fetched data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cachedClearanceData', json.encode(data));
        }
      } else {
        // Handle empty or null data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to fetch clearance data."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? _buildShimmerEffect() // Show shimmer effect while loading
                : _buildSemesterList(),
          ),
          const SizedBox(height: 16),
          _buildUpdateButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Account Clearance",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Semester-wise clearance status",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterList() {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          elevation: 4,
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["semesterName"] ?? "Unknown Semester",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusIndicator(
                      label: 'Registration',
                      status: item["registration"] ?? false,
                    ),
                    _StatusIndicator(
                      label: 'Mid',
                      status: item["midTermExam"] ?? false,
                    ),
                    _StatusIndicator(
                      label: 'Final',
                      status: item["finalExam"] ?? false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5, // Show 5 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            color: Colors.white,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      Container(
                        width: 50,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      Container(
                        width: 50,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton.icon(
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Iconsax.refresh, size: 20),
        label: Text(isLoading ? "Refreshing..." : "Refresh Status"),
        onPressed: isLoading ? null : () => _fetchClearance(refresh: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final bool status;

  const _StatusIndicator({
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          status ? Iconsax.tick_square : Iconsax.close_square,
          color: status ? Colors.green : Colors.red,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
