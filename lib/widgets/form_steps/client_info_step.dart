import 'package:flutter/material.dart';

class ClientInfoStep extends StatefulWidget {
  final num age;
  final String? sex;
  final String? customerType;
  final ValueChanged<num> onAgeChanged;
  final ValueChanged<String?> onSexChanged;
  final ValueChanged<String?> onCustomerTypeChanged;

  const ClientInfoStep({
    super.key,
    required this.age,
    required this.sex,
    required this.customerType,
    required this.onAgeChanged,
    required this.onSexChanged,
    required this.onCustomerTypeChanged,
  });

  @override
  State<ClientInfoStep> createState() => _ClientInfoStepState();
}

class _ClientInfoStepState extends State<ClientInfoStep> {
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ageController.text = widget.age.toString();
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

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
          children: [
            // CSM Description at the top of Client Info step
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Text(
                'The Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide better service. Personal information shared will be kept confidential and you always have the option to not answer this form. ANTI-RED TAPE AUTHORITY PSA Approval No. ARTA-2242-3',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Client Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                helperText: 'Must be greater than 12',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter age';
                final int? age = int.tryParse(value);
                if (age == null) return 'Must be a number';
                if (age <= 12) return 'Age must be greater than 12';
                if (age > 120) return 'Please enter a valid age';
                return null;
              },
              onSaved: (value) {
                final int? age = int.tryParse(value ?? '0');
                if (age != null && age > 12) {
                  widget.onAgeChanged(age);
                }
              },
            ),
            const SizedBox(height: 25),
            const Text('Sex', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Male'),
              value: 'Male',
              groupValue: widget.sex,
              onChanged: widget.onSexChanged,
            ),
            RadioListTile<String>(
              title: const Text('Female'),
              value: 'Female',
              groupValue: widget.sex,
              onChanged: widget.onSexChanged,
            ),
            const SizedBox(height: 25),
            const Text('Customer Type', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Business (private school, corporations, etc.)'),
              value: 'Business',
              groupValue: widget.customerType,
              onChanged: widget.onCustomerTypeChanged,
            ),
            RadioListTile<String>(
              title: const Text('Citizen (general public, learners, parents, former DepEd employees, researchers, NGOs etc.)'),
              value: 'Citizen',
              groupValue: widget.customerType,
              onChanged: widget.onCustomerTypeChanged,
            ),
            RadioListTile<String>(
              title: const Text('Government (current DepEd employees or employees of other government agencies & LGUs)'),
              value: 'Government',
              groupValue: widget.customerType,
              onChanged: widget.onCustomerTypeChanged,
            ),
          ],
        ),
      ),
    );
  }
}
