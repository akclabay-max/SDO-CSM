class AppConstants {
  static const List<String> services = [
    'Consultation',
    'Travel authority',
    'Other requests/inquiries',
    'Feedback/Complaint',
    'Issuance of Foreign Official Travel Authority',
    'Issuance of Foreign Personal Travel Authority',
    'BAC (Bids and Awards Committee)',
    'Cash Advance',
    'General Services-related',
    'Procurement-related',
  ];

  static const Map<String, String> charterOptions = {
    'Yes - easy to find': 'Yes - it was easy to find',
    'Yes - hard to find': 'Yes - but it was hard to find',
    'No': 'No',
  };

  static const List<String> sexOptions = ['Male', 'Female'];
  
  static const List<String> customerTypes = [
    'Business',
    'Citizen',
    'Government',
  ];
}