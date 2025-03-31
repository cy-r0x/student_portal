import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

String formatCurrency(double amount) {
  final format = NumberFormat.currency(locale: 'en_US', symbol: 'BDT ');
  return format.format(amount);
}

class AmountCard extends StatelessWidget {
  final String cardType;
  final double amountCredit;
  final Color bgColor;
  final bool isRefreshing;

  const AmountCard({
    Key? key,
    required this.cardType,
    required this.amountCredit,
    required this.bgColor,
    required this.isRefreshing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: bgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          height: 140,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cardType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              (isRefreshing
                  ? Shimmer.fromColors(
                      baseColor: bgColor.withOpacity(0.7),
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 250,
                        height: 36,
                        color: bgColor.withOpacity(0.7),
                      ),
                    )
                  : Text(
                      formatCurrency(amountCredit),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
