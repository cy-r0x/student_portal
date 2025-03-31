import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  final String? message;

  const Spinner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.black, // Black-colored spinner
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black, // Black-colored text
              ),
            ),
          ],
        ],
      ),
    );
  }
}
