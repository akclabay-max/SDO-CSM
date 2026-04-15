import 'package:flutter/material.dart';
import '../models/form_data.dart';
import '../utils/snackbar_helper.dart';
import 'form_steps/client_info_step.dart';
import 'form_steps/services_step.dart';
import 'form_steps/citizens_charter_step.dart';
import 'form_steps/satisfaction_step.dart';
import '../services/firestore_service.dart'; 

class ServiceForm extends StatefulWidget {
  const ServiceForm({super.key});

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  late ScrollController _scrollController;
  int _currentStep = 0;
  final FormData _formData = FormData();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<String> stepTitles = [
    'Client Information',
    'Offices and Services',
    "Citizen's Charter",
    'Client Satisfaction',
    'Remarks',
  ];

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (!_validateCurrentStep()) {
        return;
      }
      
      if (_currentStep < stepTitles.length - 1) {
        setState(() => _currentStep++);
        _scrollToTop();
      } else {
        _submitForm();
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_formData.age <= 12) {
          SnackbarHelper.showError(context, 'Please enter age higher than 12');
          return false;
        }
        if (_formData.sex == null) {
          SnackbarHelper.showError(context, 'Please select sex');
          return false;
        }
        if (_formData.customerType == null) {
          SnackbarHelper.showError(context, 'Please select customer type');
          return false;
        }
        break;
      case 1:
        if (_formData.selectedService.isEmpty) {
          SnackbarHelper.showError(context, 'Please select a service');
          return false;
        }
        break;
      case 2:
        if (_formData.citizenCharterAwareness == null) {
          SnackbarHelper.showError(context, 'Please answer the Citizen\'s Charter awareness question');
          return false;
        }
        if (_formData.citizenCharterUsed == null) {
          SnackbarHelper.showError(context, 'Please answer if you used the Citizen\'s Charter');
          return false;
        }
        break;
      case 3:
        bool allRatingsFilled = _formData.satisfactionRatings.every((r) => r != null);
        if (!allRatingsFilled) {
          SnackbarHelper.showError(context, 'Please answer all satisfaction questions');
          return false;
        }
        break;
    }
    return true;
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _submitForm() async {
    // Validate first
    if (!_formData.isValid()) {
      SnackbarHelper.showError(context, 'Please complete all required fields');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Submitting form...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Prepare ratings list
      List<Map<String, dynamic>> ratingsList = [];
      
      for (int i = 0; i < _formData.satisfactionRatings.length; i++) {
        int? ratingValue = _formData.satisfactionRatings[i];
        String ratingLabel = _getRatingLabel(ratingValue ?? 0);
        
        ratingsList.add({
          'question_id': i + 1,
          'question_code': _getQuestionCode(i),
          'rating_value': ratingValue,
          'rating_label': ratingLabel,
        });
      }
      
      // Prepare complete form data
      Map<String, dynamic> formDataToSave = {
        'age': _formData.age,
        'sex': _formData.sex,
        'customerType': _formData.customerType,
        'selectedService': _formData.selectedService,
        'selectedOffice': _formData.selectedOffice,
        'citizenCharterAwareness': _formData.citizenCharterAwareness,
        'citizenCharterUsed': _formData.citizenCharterUsed,
        'remarks': _formData.remarks, // Now using _formData.remarks
        'satisfactionRatings': ratingsList,
        'submittedAt': DateTime.now().toIso8601String(),
      };
      
      print('Saving form data: $formDataToSave');
      
      // Save to Firestore
      await _firestoreService.saveFormSubmission(formDataToSave);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Calculate average rating
      double averageRating = _calculateAverageRating();
      print('Average Rating: $averageRating');
      
      // Show success message
      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Form submitted successfully!');
      }
      
      // Reset form after submission
      _resetForm();
      
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      // Show error message
      print('Error: $e');
      if (mounted) {
        SnackbarHelper.showError(context, 'Error submitting form: $e');
      }
    }
  }
  
  void _resetForm() {
    setState(() {
      _formData.age = 0;
      _formData.sex = null;
      _formData.customerType = null;
      _formData.selectedService = '';
      _formData.selectedOffice = '';
      _formData.citizenCharterAwareness = null;
      _formData.citizenCharterUsed = null;
      _formData.satisfactionRatings = List.filled(8, null);
      _formData.remarks = '';
      _currentStep = 0;
    });
  }

  String _getQuestionCode(int index) {
    switch (index) {
      case 0: return 'SQD1';
      case 1: return 'SQD2';
      case 2: return 'SQD3';
      case 3: return 'SQD4';
      case 4: return 'SQD5';
      case 5: return 'SQD6';
      case 6: return 'SQD7';
      case 7: return 'SQD8';
      default: return 'Unknown';
    }
  }

  String _getRatingLabel(int value) {
    switch (value) {
      case 0: return 'Not Applicable';
      case 1: return 'Strongly Disagree';
      case 2: return 'Disagree';
      case 3: return 'Neutral';
      case 4: return 'Agree';
      case 5: return 'Strongly Agree';
      default: return 'Not Rated';
    }
  }

  double _calculateAverageRating() {
    List<int?> nonNullRatings = _formData.satisfactionRatings
        .where((r) => r != null && r != 0)
        .toList();
    
    if (nonNullRatings.isEmpty) return 0.0;
    
    int sum = nonNullRatings.fold(0, (total, rating) => total + (rating ?? 0));
    return sum / nonNullRatings.length;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Step content with description scrolling - Expanded
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
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
            ),
          ),
          // Navigation section with step indicator at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                // Step indicator (page tracker) at bottom
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(stepTitles.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: _currentStep == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _currentStep == index ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                // Back and Next/Submit buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 110,
                      child: _currentStep > 0
                          ? ElevatedButton(
                              onPressed: _previousStep,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                minimumSize: const Size.fromHeight(40),
                              ),
                              child: const Text('Back'),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(
                      width: 110,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentStep == stepTitles.length - 1
                              ? const Color.fromARGB(255, 90, 156, 243)
                              : null,
                          foregroundColor: _currentStep == stepTitles.length - 1
                              ? Colors.white
                              : null,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: Text(_currentStep == stepTitles.length - 1 ? 'Submit' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return ClientInfoStep(
          age: _formData.age,
          sex: _formData.sex,
          customerType: _formData.customerType,
          onAgeChanged: (value) => setState(() => _formData.age = value),
          onSexChanged: (value) => setState(() => _formData.sex = value),
          onCustomerTypeChanged: (value) => setState(() => _formData.customerType = value),
        );
      case 1:
        return ServicesStep(
          selectedService: _formData.selectedService,
          selectedOffice: _formData.selectedOffice,
          onServiceChanged: (value) => setState(() => _formData.selectedService = value),
          onOfficeChanged: (value) => setState(() => _formData.selectedOffice = value),
        );
      case 2: 
        return CitizenCharterStep(
          awareness: _formData.citizenCharterAwareness,
          used: _formData.citizenCharterUsed,
          onAwarenessChanged: (value) => setState(() => _formData.citizenCharterAwareness = value),
          onUsedChanged: (value) => setState(() => _formData.citizenCharterUsed = value),
        );
      case 3:
        return SatisfactionStep(
          ratings: _formData.satisfactionRatings,
          onRatingChanged: (index, value) {
            setState(() {
              _formData.satisfactionRatings[index] = value;
            });
          },
        );
      case 4:
        return _buildRemarksStep();
      default:
        return const Center(child: Text('Loading...'));
    }
  }

  Widget _buildRemarksStep() {
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
              'Remarks / Additional Comments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'We value your feedback! Please share any additional comments or suggestions to help us improve our services.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _formData.remarks,
              decoration: const InputDecoration(
                labelText: 'Your remarks',
                hintText: 'Enter your comments, suggestions, or feedback here...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment),
                helperText: 'Maximum 500 characters',
              ),
              maxLines: 5,
              maxLength: 500,
              onChanged: (value) {
                setState(() {
                  _formData.remarks = value; // Update _formData.remarks
                });
              },
              onSaved: (value) {
                _formData.remarks = value ?? '';
              },
            ),
          ],
        ),
      ),
    );
  }
}