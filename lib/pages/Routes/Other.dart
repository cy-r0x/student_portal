import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class Other extends StatelessWidget {
  const Other({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.programming_arrows,
            size: 50,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            "Will be available in the next update.",
            style: TextStyle(
              fontSize: 34,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
