import 'package:flutter/material.dart';

class CitizenCharterStep extends StatelessWidget {
  final String? awareness;
  final String? used;
  final ValueChanged<String?> onAwarenessChanged;
  final ValueChanged<String?> onUsedChanged;

  const CitizenCharterStep({
    super.key,
    required this.awareness,
    required this.used,
    required this.onAwarenessChanged,
    required this.onUsedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          child: Column(
                children: [
                  // Description text that now scrolls with content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: const Text(
                      'The Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide better service. Personal information shared will be kept confidential and you always have the option to not answer this form. ANTI-RED TAPE AUTHORITY PSA Approval No. ARTA-2242-3',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  _buildStepContent(),
                  const SizedBox(height: 16),
                ],
              ),
          children: [
            const Text(
              "Citizen's Charter",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            const Text(
              "Are you aware of the Citizen's Charter - document of the SDO services and requirements?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              title: const Text('Yes - it was easy to find'),
              value: 'Yes - easy to find',
              groupValue: awareness,
              onChanged: onAwarenessChanged,
            ),
            RadioListTile<String>(
              title: const Text('Yes - but it was hard to find'),
              value: 'Yes - hard to find',
              groupValue: awareness,
              onChanged: onAwarenessChanged,
            ),
            RadioListTile<String>(
              title: const Text('No'),
              value: 'No',
              groupValue: awareness,
              onChanged: onAwarenessChanged,
            ),
            const SizedBox(height: 25),
            const Text(
              "Did you use the SDO Citizen's Charter as a guide for the service you availed?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              title: const Text('Yes'),
              value: 'Yes',
              groupValue: used,
              onChanged: onUsedChanged,
            ),
            RadioListTile<String>(
              title: const Text('No'),
              value: 'No',
              groupValue: used,
              onChanged: onUsedChanged,
            ),
          ],
        ),
      ),
    );
  }
}
