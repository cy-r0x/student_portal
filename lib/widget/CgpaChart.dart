import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:shimmer/shimmer.dart';

class CGPACircularChart extends StatelessWidget {
  final List<Map<String, dynamic>> sgpaData;
  final bool isRefreshing;

  const CGPACircularChart({
    super.key,
    required this.sgpaData,
    required this.isRefreshing,
  });

  double _calculateCGPA() {
    if (sgpaData.isEmpty) return 0.0;
    double total = 0;
    for (final item in sgpaData) {
      total += item['sgpa'] as double;
    }
    return total / sgpaData.length;
  }

  @override
  Widget build(BuildContext context) {
    final double cgpa = _calculateCGPA();

    if (isRefreshing) {
      // Return shimmer effect when refreshing
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Return the CGPA chart when not refreshing
    return Card(
      color: Colors.white,
      elevation: 2,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        animationDuration: 1500,
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 4.0,
            startAngle: 0,
            endAngle: 360,
            radiusFactor: 0.9,
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 40,
              color: Colors.grey.shade300,
              thicknessUnit: GaugeSizeUnit.logicalPixel,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: cgpa,
                width: 40,
                cornerStyle: CornerStyle.bothCurve,
                sizeUnit: GaugeSizeUnit.logicalPixel,
                gradient: const SweepGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF2563EB)],
                  stops: [0.25, 0.75],
                ),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                angle: 90,
                positionFactor: 0,
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CGPA',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A)),
                    ),
                    Text(
                      cgpa.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Text(
                      'out of 4.00',
                      style: TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
