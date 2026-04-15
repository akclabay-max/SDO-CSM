import 'package:flutter/material.dart';

// RatingRadioList widget
class RatingRadioList extends StatefulWidget {
  final String title;
  final Function(int?) onChanged;
  final int? initialValue;

  const RatingRadioList({
    super.key,
    required this.title,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<RatingRadioList> createState() => _RatingRadioListState();
}

class _RatingRadioListState extends State<RatingRadioList> {
  int? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive button size: smaller on mobile, larger on desktop
    final buttonSize = screenWidth < 480 ? 32.0 : screenWidth < 768 ? 36.0 : 40.0;
    final borderWidth = screenWidth < 480 ? 1.5 : 2.0;
    final fontSize = screenWidth < 480 ? 14.0 : 16.0;
    final labelFontSize = screenWidth < 480 ? 7.0 : 9.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth < 480 ? 12 : 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedValue = index;
                  });
                  widget.onChanged(_selectedValue);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedValue == index
                            ? const Color.fromARGB(255, 90, 156, 243)
                            : Colors.grey[200],
                        border: Border.all(
                          color: _selectedValue == index
                              ? const Color.fromARGB(255, 90, 156, 243)
                              : Colors.grey[400]!,
                          width: borderWidth,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          index.toString(),
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: _selectedValue == index
                                ? Colors.white
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: screenWidth < 480 ? 24 : 28,
                      child: Text(
                        _getRatingLabel(index),
                        style: TextStyle(
                          fontSize: labelFontSize,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        // Display selected value
        if (_selectedValue != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Selected: ${_getRatingLabel(_selectedValue!)} ($_selectedValue)',
                style: TextStyle(fontSize: 11, color: Colors.green[800]),
              ),
            ),
          ),
      ],
    );
  }

  String _getRatingLabel(int value) {
    switch (value) {
      case 0: return 'Not Applicable';
      case 1: return 'Strongly Disagree';
      case 2: return 'Disagree';
      case 3: return 'Neutral';
      case 4: return 'Agree';
      case 5: return 'Strongly Agree';
      default: return '';
    }
  }
}

// SatisfactionStep widget
class SatisfactionStep extends StatelessWidget {
  final List<int?> ratings;
  final Function(int, int?) onRatingChanged;

  const SatisfactionStep({
    super.key,
    required this.ratings,
    required this.onRatingChanged,
  });

  final List<Map<String, String>> questions = const [
    {'id': 'SQD1', 'text': 'I spent an acceptable amount of time to complete my transaction (Responsiveness)'},
    {'id': 'SQD2', 'text': "The office accurately informed and followed the transaction's requirements and steps (Reliability)"},
    {'id': 'SQD3', 'text': 'My transaction (including steps and payment) was simple and convenient (Access and Facilities)'},
    {'id': 'SQD4', 'text': 'I easily found information about my transaction from the office or its website (Communication)'},
    {'id': 'SQD5', 'text': 'I paid an acceptable amount of fees for my transaction (Costs)'},
    {'id': 'SQD6', 'text': 'I am confident my transaction was secure (Integrity)'},
    {'id': 'SQD7', 'text': "The office's support was quick to respond (Assurance)"},
    {'id': 'SQD8', 'text': 'I got what I needed from the government office (Outcome)'},
  ];

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
              'Client Satisfaction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              child: Column(
                children: List.generate(questions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RatingRadioList(
                      title: '${questions[index]['id']} - ${questions[index]['text']}',
                      initialValue: ratings.length > index ? ratings[index] : null,
                      onChanged: (value) => onRatingChanged(index, value),
                    ),
                  );
                }),
              ),
            ),
            
            // Summary section - shows completion status
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getCompletionStatus(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getCompletionStatus() {
    int answeredCount = ratings.where((r) => r != null).length;
    int totalCount = questions.length;
    
    if (answeredCount == totalCount) {
      return '✓ All questions answered! You can proceed to the next step.';
    } else {
      return '⚠ $answeredCount of $totalCount questions answered. Please complete all ratings.';
    }
  }
}