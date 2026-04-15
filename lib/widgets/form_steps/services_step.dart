import 'package:flutter/material.dart';

// Define service mapping directly in this file
class ServiceItem {
  final String name;
  final String office;
  
  ServiceItem({required this.name, required this.office});
  
  @override
  String toString() => name;
}

// List of services with their assigned offices
final List<ServiceItem> servicesWithOffices = [
  // GENERAL Office
  ServiceItem(name: 'Feedback / Complaint', office: 'GENERAL'),
  ServiceItem(name: 'Other requests / inquiries', office: 'GENERAL'),

  //SDS
  ServiceItem(name: 'Travel authority', office: 'SDS'),
  ServiceItem(name: 'Issuance of Foreign Official Travel Authority', office: 'SDS'),
  ServiceItem(name: 'Issuance of Foreign Personal Travel Authority', office: 'SDS'),

  //ASDS
  ServiceItem(name: 'BAC (Bids and Awards Committee)', office: 'ASDS'),

  //ADMIN CASH
  ServiceItem(name: 'Cash Advance', office: 'ADMIN CASH'),
  ServiceItem(name: 'General Services-related', office: 'ADMIN CASH'),
  ServiceItem(name: 'Procurement-related', office: 'ADMIN CASH'),

  //ADMIN PERSONNEL
  ServiceItem(name: 'Application for Non-teaching / Teaching-related Position', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Application - Non-teaching/Teaching-related', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Appointment (original, reemployment, reappointment, promotion, transfer)', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Certificate of Employment (COE)', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Correction of Name / Change of Status', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Equivalent Record Form (ERF)', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Leave Application', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Loan Approval and Verification', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Retirement', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Service Record', office: 'ADMIN PERSONNEL'),
  ServiceItem(name: 'Terminal Leave Benefits', office: 'ADMIN PERSONNEL'),

  //ADMIN PROPERTY AND SUPPLY
  ServiceItem(name: 'Certification, Authentication, Verification (CAV)', office: 'ADMIN PROPERTY AND SUPPLY'),
  ServiceItem(name: 'Certified True Copy (CTC)/ Photocopy of documents', office: 'ADMIN PROPERTY AND SUPPLY'),
  ServiceItem(name: 'Non-Certified True Copy documents', office: 'ADMIN PROPERTY AND SUPPLY'),
  ServiceItem(name: 'Complaints against non-teaching personnel', office: 'ADMIN PROPERTY AND SUPPLY'),
  ServiceItem(name: 'Receiving and releasing of communication and other documents', office: 'ADMIN PROPERTY AND SUPPLY'),
  ServiceItem(name: 'Inspection / Acceptance / Distribution of LRs, Supplies & Equipment', office: 'ADMIN PROPERTY AND SUPPLY'),
  ServiceItem(name: 'Property and Equipment Clearance', office: 'ADMIN PROPERTY AND SUPPLY'),
  ServiceItem(name: 'Request / Issuance of Supplies', office: 'ADMIN PROPERTY AND SUPPLY'),

  //CID
  ServiceItem(name: 'ALS (Alternative Learning System) Enrollment', office: 'CID'),
  ServiceItem(name: 'Access to LR / LRMDS Portal', office: 'CID'),
  ServiceItem(name: 'Borrowing of Books / Learning Materials', office: 'CID'),
  ServiceItem(name: 'Submission of Contextualized Learning Resources', office: 'CID'),
  ServiceItem(name: 'Quality Assurance of Supplementary Learning Resources', office: 'CID'),
  ServiceItem(name: 'Instructional Supervision', office: 'CID'),
  ServiceItem(name: 'Technical Assistance', office: 'CID'),

  //FINANCE
  ServiceItem(name: 'Accounting-Related', office: 'FINANCE'),
  ServiceItem(name: 'ORS (Obligation Request and Status) Processing', office: 'FINANCE'),
  ServiceItem(name: 'Posting / Updating of Disbursement', office: 'FINANCE'),

  //ICT
  ServiceItem(name: 'Create / Delete / Rename / Reset User Accounts', office: 'ICT'),
  ServiceItem(name: 'Troubleshooting of ICT Equipment', office: 'ICT'),
  ServiceItem(name: 'Uploading of Publications', office: 'ICT'),

  //LEGAL
  ServiceItem(name: 'Certificate of No Pending Case', office: 'LEGAL'),
  ServiceItem(name: 'Correction of Entries in School Record', office: 'LEGAL'),
  ServiceItem(name: 'Legal Advice / Opinion', office: 'LEGAL'),
  ServiceItem(name: 'Sites Titling', office: 'LEGAL'),

  //SGOD
  ServiceItem(name: 'Basic Education Data (Internal Stakeholder)', office: 'SGOD'),
  ServiceItem(name: 'Basic Education Data (External Stakeholder)', office: 'SGOD'),
  ServiceItem(name: 'EBEIS / LIS / NAT Data and Performance Indicators', office: 'SGOD'),
  ServiceItem(name: 'Private School: Application for Increase in Tuition Fee', office: 'SGOD'),
  ServiceItem(name: 'Private School: Application for No Increase in Tuition Fee', office: 'SGOD'),
  ServiceItem(name: 'Private School: Application for Additional SHS Track or Stand', office: 'SGOD'),
  ServiceItem(name: 'Private School: Application for Summer Permit', office: 'SGOD'),
  ServiceItem(name: 'Private School: Issuance of Government Permit / Renewal / Recognition', office: 'SGOD'),
  ServiceItem(name: 'Private School: Issuance of Special Order for Graduation', office: 'SGOD'),
];

class ServicesStep extends StatefulWidget {
  final String selectedService;
  final String? selectedOffice; 
  final ValueChanged<String> onServiceChanged;
  final ValueChanged<String>? onOfficeChanged;

  const ServicesStep({
    super.key,
    required this.selectedService,
    required this.selectedOffice,
    required this.onServiceChanged,
    this.onOfficeChanged,
  });

  @override
  State<ServicesStep> createState() => _ServicesStepState();
}

class _ServicesStepState extends State<ServicesStep> {
  final TextEditingController _serviceController = TextEditingController();
  String _selectedOffice = '';

  @override
  void initState() {
    super.initState();
    _serviceController.text = widget.selectedService;
    if (widget.selectedService.isNotEmpty) {
      final service = servicesWithOffices.firstWhere(
        (s) => s.name == widget.selectedService,
        orElse: () => ServiceItem(name: '', office: ''),
      );
      _selectedOffice = service.office;
    }
  }

  @override
  void dispose() {
    _serviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Offices and Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Show selected service with office
            if (widget.selectedService.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Service:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.selectedService,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (_selectedOffice.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Office: $_selectedOffice',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Autocomplete for service selection - FIXED VERSION
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                // Get all service names as strings
                List<String> serviceNames = servicesWithOffices.map((service) => service.name).toList();
                
                if (textEditingValue.text.isEmpty) {
                  return serviceNames;
                }
                return serviceNames.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                // Find the office for the selected service
                final selectedService = servicesWithOffices.firstWhere(
                  (service) => service.name == selection,
                  orElse: () => ServiceItem(name: '', office: ''),
                );
                
                setState(() {
                  _serviceController.text = selection;
                  _selectedOffice = selectedService.office;
                  widget.onServiceChanged(selection);
                  if (widget.onOfficeChanged != null) {
                    widget.onOfficeChanged!(selectedService.office);
                  }
                });
                
                // Show snackbar with office info
                if (selectedService.office.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('This service is handled by: ${selectedService.office}'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController fieldController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                // Sync the controller
                if (fieldController.text != _serviceController.text) {
                  fieldController.text = _serviceController.text;
                }
                return TextFormField(
                  controller: fieldController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Select or type service',
                    border: OutlineInputBorder(),
                    helperText: 'Start typing to search services. Select a service to see which office handles it.',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required field';
                    }
                    // Validate that the entered value exists in the service list
                    bool isValid = servicesWithOffices.any((service) => service.name == value);
                    if (!isValid) {
                      return 'Please select a valid service from the list';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      widget.onServiceChanged(value);
                      // Also save the office
                      final service = servicesWithOffices.firstWhere(
                        (s) => s.name == value,
                        orElse: () => ServiceItem(name: '', office: ''),
                      );
                      if (widget.onOfficeChanged != null) {
                        widget.onOfficeChanged!(service.office);
                      }
                    }
                  },
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Hint text
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}