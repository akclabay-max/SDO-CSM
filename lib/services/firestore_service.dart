import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Collection reference for form submissions
  final CollectionReference _formSubmissionsCollection = 
      FirebaseFirestore.instance.collection('form_submissions');
  
  // Save complete form data to Firestore
  Future<void> saveFormSubmission(Map<String, dynamic> formData) async {
  try {
    await _formSubmissionsCollection.add({
      ...formData,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Form submitted successfully to Firestore!');
  } catch (e) {
    print('Error saving form submission: $e');
    throw e;
  }
}
  
  // Get all form submissions (real-time updates)
  Stream<QuerySnapshot> getFormSubmissionsStream() {
    return _formSubmissionsCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Get form submissions once (no real-time updates)
  Future<QuerySnapshot> getFormSubmissionsOnce() async {
    return await _formSubmissionsCollection
        .orderBy('timestamp', descending: true)
        .get();
  }
  
  // Get submissions by customer type
  Stream<QuerySnapshot> getSubmissionsByCustomerType(String customerType) {
    return _formSubmissionsCollection
        .where('customerType', isEqualTo: customerType)
        .snapshots();
  }
  
  // Get submissions by service
  Stream<QuerySnapshot> getSubmissionsByService(String serviceName) {
    return _formSubmissionsCollection
        .where('selectedService', isEqualTo: serviceName)
        .snapshots();
  }

  // Get submissions by office
  Stream<QuerySnapshot> getSubmissionsByOffice(String officeName) {
    return _formSubmissionsCollection
        .where('selectedOffice', isEqualTo: officeName)
        .snapshots();
  }
  
  // Get submissions by date range
  Future<QuerySnapshot> getSubmissionsByDateRange(
    DateTime startDate, 
    DateTime endDate,
  ) async {
    return await _formSubmissionsCollection
        .where('submittedAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('submittedAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('submittedAt', descending: true)
        .get();
  }
  
  // Get average rating for a specific question
  Future<double> getAverageRatingForQuestion(String questionCode) async {
    final snapshot = await _formSubmissionsCollection.get();
    
    if (snapshot.docs.isEmpty) return 0.0;
    
    double total = 0;
    int count = 0;
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final ratings = data['satisfactionRatings'] as List<dynamic>?;
      
      if (ratings != null) {
        // Find the rating for the specific question
        for (var rating in ratings) {
          if (rating['question_code'] == questionCode) {
            final value = rating['rating_value'];
            if (value != null && value != 0) {
              total += value;
              count++;
            }
            break;
          }
        }
      }
    }
    
    return count > 0 ? total / count : 0.0;
  }
  
  // Get statistics summary
  Future<Map<String, dynamic>> getStatistics() async {
    final snapshot = await _formSubmissionsCollection.get();
    
    if (snapshot.docs.isEmpty) {
      return {
        'totalSubmissions': 0,
        'averageAge': 0.0,
        'genderDistribution': {'Male': 0, 'Female': 0},
        'customerTypeDistribution': {},
        'averageOverallRating': 0.0,
        'topOffices': <Map<String, dynamic>>[],
        'topServices': <Map<String, dynamic>>[],
      };
    }
    
    int totalSubmissions = snapshot.docs.length;
    num totalAge = 0;
    int maleCount = 0;
    int femaleCount = 0;
    Map<String, int> customerTypeCount = {};
    Map<String, int> officeCount = {};
    Map<String, int> serviceCount = {};
    List<double> allRatings = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Age
      totalAge += data['age'] ?? 0;
      
      // Gender
      if (data['sex'] == 'Male') maleCount++;
      if (data['sex'] == 'Female') femaleCount++;
      
      // Customer Type
      String type = data['customerType'] ?? 'Unknown';
      customerTypeCount[type] = (customerTypeCount[type] ?? 0) + 1;

      // Office
      final office = (data['selectedOffice'] as String?)?.trim();
      if (office != null && office.isNotEmpty) {
        officeCount[office] = (officeCount[office] ?? 0) + 1;
      }

      // Service
      final service = (data['selectedService'] as String?)?.trim();
      if (service != null && service.isNotEmpty) {
        serviceCount[service] = (serviceCount[service] ?? 0) + 1;
      }
      
      // Ratings
      final ratings = data['satisfactionRatings'] as List<dynamic>?;
      if (ratings != null) {
        for (var rating in ratings) {
          final value = rating['rating_value'];
          if (value != null && value != 0) {
            allRatings.add(value.toDouble());
          }
        }
      }
    }
    
    double avgOverallRating = allRatings.isNotEmpty 
        ? allRatings.reduce((a, b) => a + b) / allRatings.length 
        : 0.0;

    final topOfficesEntries = officeCount.entries.toList();
    topOfficesEntries.sort((a, b) => b.value.compareTo(a.value));
    final topOffices = topOfficesEntries.take(3).map((entry) => {
      'label': entry.key,
      'count': entry.value,
    }).toList();

    final topServicesEntries = serviceCount.entries.toList();
    topServicesEntries.sort((a, b) => b.value.compareTo(a.value));
    final topServices = topServicesEntries.take(3).map((entry) => {
      'label': entry.key,
      'count': entry.value,
    }).toList();
    
    return {
      'totalSubmissions': totalSubmissions,
      'averageAge': totalAge / totalSubmissions,
      'genderDistribution': {'Male': maleCount, 'Female': femaleCount},
      'customerTypeDistribution': customerTypeCount,
      'averageOverallRating': avgOverallRating,
      'topOffices': topOffices,
      'topServices': topServices,
    };
  }
  
  // Update a submission (if needed for admin edits)
  Future<void> updateSubmission(String docId, Map<String, dynamic> updatedData) async {
    try {
      await _formSubmissionsCollection.doc(docId).update({
        ...updatedData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('Submission updated successfully!');
    } catch (e) {
      print('Error updating submission: $e');
      throw e;
    }
  }
  
  // Delete a submission
  Future<void> deleteSubmission(String docId) async {
    try {
      await _formSubmissionsCollection.doc(docId).delete();
      print('Submission deleted successfully!');
    } catch (e) {
      print('Error deleting submission: $e');
      throw e;
    }
  }
  
  // Get submission by ID
  Future<Map<String, dynamic>?> getSubmissionById(String docId) async {
    try {
      final doc = await _formSubmissionsCollection.doc(docId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting submission: $e');
      return null;
    }
  }
}