import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ScrollableHorizontalBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> sgpaData;
  final bool isRefreshing;

  const ScrollableHorizontalBarChart({
    super.key,
    required this.sgpaData,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    if (isRefreshing) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: sgpaData.length * 80.0,
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelRotation: 45,
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 4.0,
              interval: 0.5,
            ),
            tooltipBehavior: TooltipBehavior(enable: false),
            series: <CartesianSeries>[
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: sgpaData,
                xValueMapper: (data, _) => data['semester'],
                yValueMapper: (data, _) => data['sgpa'],
                color: Colors.blueAccent,
                width: 50 / 80.0,
                borderRadius: BorderRadius.circular(5),
                dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.middle,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
