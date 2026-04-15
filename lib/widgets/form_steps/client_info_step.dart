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
            const Text(
              'Client Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter age';
                if (int.tryParse(value) == null) return 'Must be a number';
                return null;
              },
              onSaved: (value) => widget.onAgeChanged(int.tryParse(value ?? '0') ?? 0),
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