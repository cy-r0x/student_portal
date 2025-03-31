import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package
import 'package:student_portal/utils/fetchCredit.dart';
import 'package:student_portal/utils/fetchSgpa.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/AmountCard.dart';
import '../../widget/BarChart.dart';
import '../../widget/CgpaChart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.accessToken,
  });

  final String accessToken;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? creditData;
  List<Map<String, dynamic>>? sgpaData;
  bool isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedCredit = prefs.getString('cachedCreditData');
      final cachedSGPA = prefs.getString('cachedSGPAData');

      if (mounted) {
        setState(() {
          creditData = cachedCredit != null ? json.decode(cachedCredit) : null;
          sgpaData = cachedSGPA != null
              ? List<Map<String, dynamic>>.from(json.decode(cachedSGPA))
              : null;
        });
      }

      if (creditData == null || sgpaData == null) {
        await _handleRefresh(true);
      }
    } catch (e) {
      _updateError("Error loading cached data: ${e.toString()}");
    }
  }

  Future<void> _handleRefresh([bool silent = false]) async {
    if (!silent && mounted) setState(() => isRefreshing = true);

    try {
      final results = await Future.wait([
        getCreditData(widget.accessToken),
        fetchSGPA(widget.accessToken),
      ]);

      if (results[0] == null || results[1] == null) {
        throw Exception("Failed to fetch data from the server.");
      }

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('cachedCreditData', json.encode(results[0])),
        prefs.setString('cachedSGPAData', json.encode(results[1])),
      ]);

      if (mounted) {
        setState(() {
          creditData = results[0] as Map<String, dynamic>;
          sgpaData = results[1] as List<Map<String, dynamic>>;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _updateError("Refresh failed: ${e.toString()}");
    } finally {
      if (mounted && !silent) setState(() => isRefreshing = false);
    }
  }

  void _updateError(String message) {
    if (mounted) setState(() => _errorMessage = message);
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                height: 24,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Column(
                children: List.generate(
                  4,
                  (index) => Container(
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 150,
                height: 24,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 150,
                height: 24,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(24, 24, 27, 1),
          ),
        ),
        ElevatedButton.icon(
          icon: isRefreshing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Iconsax.refresh, size: 20),
          label: Text(isRefreshing ? "Refreshing..." : "Refresh Dashboard"),
          onPressed: isRefreshing ? null : () => _handleRefresh(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAmountCards() {
    return [
      AmountCard(
        cardType: "Total Payable",
        amountCredit: creditData!["totalDebit"]?.toDouble() ?? 0.0,
        bgColor: Colors.blueAccent,
        isRefreshing: isRefreshing,
      ),
      AmountCard(
        cardType: "Total Paid",
        amountCredit: creditData!["totalCredit"]?.toDouble() ?? 0.0,
        bgColor: Colors.purple,
        isRefreshing: isRefreshing,
      ),
      AmountCard(
        cardType: "Total Due",
        amountCredit: (creditData!["totalDebit"]?.toDouble() ?? 0.0) -
            (creditData!["totalCredit"]?.toDouble() ?? 0.0),
        bgColor: Colors.redAccent,
        isRefreshing: isRefreshing,
      ),
      AmountCard(
        cardType: "Others",
        amountCredit: creditData!["totalOther"]?.toDouble() ?? 0.0,
        bgColor: Colors.teal,
        isRefreshing: isRefreshing,
      ),
    ];
  }

  Widget _buildCGPASection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Overall CGPA",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        sgpaData != null && sgpaData!.isNotEmpty
            ? CGPACircularChart(
                sgpaData: sgpaData!,
                isRefreshing: isRefreshing,
              )
            : const Text("No CGPA data available",
                style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSGPASection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SGPA Graph",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        sgpaData != null && sgpaData!.isNotEmpty
            ? ScrollableHorizontalBarChart(
                sgpaData: sgpaData!,
                isRefreshing: isRefreshing,
              )
            : const Text("No SGPA data available",
                style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            ..._buildAmountCards(),
            const SizedBox(height: 24),
            _buildCGPASection(),
            const SizedBox(height: 24),
            _buildSGPASection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleRefresh(true),
              child: const Text("Try Again"),
            ),
          ],
        ),
      );
    }

    if (creditData == null || sgpaData == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildShimmerEffect(),
      );
    }

    return _buildDashboard();
  }
}
