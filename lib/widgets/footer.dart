import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  final String organizationName;
  final String systemName;
  final int? currentYear;
  
  const CustomFooter({
    super.key,
    required this.systemName, // Made required
    this.organizationName = 'SDO Baguio City',
    this.currentYear,
  });

  @override
  Widget build(BuildContext context) {
    final year = currentYear ?? DateTime.now().year;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.copyright, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$year $organizationName.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            systemName,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}