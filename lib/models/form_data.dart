class FormData {
  num age;
  String? sex;
  String? customerType;
  String selectedService;
  String? citizenCharterAwareness;
  String? citizenCharterUsed;
  String? selectedOffice;
  String? remarks;
  List<int?> satisfactionRatings;

  FormData({
    this.age = 0,
    this.sex,
    this.customerType,
    this.selectedService = '',
    this.selectedOffice = '',
    this.citizenCharterAwareness,
    this.citizenCharterUsed,
    this.remarks = '',
    List<int?>? satisfactionRatings,
  }) : satisfactionRatings = satisfactionRatings ?? List.filled(8, null); 

  bool isValid() {
    return sex != null &&
        customerType != null &&
        citizenCharterAwareness != null &&
        citizenCharterUsed != null &&
        selectedService.isNotEmpty;
  }

  void printFormData() {
    print('=== Form Submission ===');
    print('Age: $age');
    print('Sex: $sex');
    print('Customer Type: $customerType');
    print('Service: $selectedService');
    print('Office: $selectedOffice');
    print('Citizen Charter Awareness: $citizenCharterAwareness');
    print('Citizen Charter Used: $citizenCharterUsed');
    print('Satisfaction Ratings: $satisfactionRatings');
    print('=====================');
  }

  
  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'sex': sex,
      'customerType': customerType,
      'selectedService': selectedService,
      'selectedOffice': selectedOffice,
      'citizenCharterAwareness': citizenCharterAwareness,
      'citizenCharterUsed': citizenCharterUsed,
      'satisfactionRatings': satisfactionRatings,
      'remarks': remarks,
      'submittedAt': DateTime.now().toIso8601String(),
    };
  }
}