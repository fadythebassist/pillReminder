import 'package:flutter/material.dart';

class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Advertisement',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
