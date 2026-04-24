class Customer {
  final int? id;
  final int partnerId;
  final String companyName;
  final String companyAddress;
  final String companyNumber;
  final String adminName;
  final String adminNumber;
  final String companyArea;
  final String companyField;
  final String remarks;
  final String additionalFeatures;
  final DateTime? registrationDateTime;
  final String status;

  Customer({
    this.id,
    required this.partnerId,
    required this.companyName,
    required this.companyAddress,
    required this.companyNumber,
    required this.adminName,
    required this.adminNumber,
    required this.companyArea,
    required this.companyField,
    required this.remarks,
    required this.additionalFeatures,
    this.registrationDateTime,
    this.status = 'Pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'partner_id': partnerId,
      'com_name': companyName,
      'com_address': companyAddress,
      'com_number': companyNumber,
      'admin_name': adminName,
      'admin_number': adminNumber,
      'com_area': companyArea,
      'com_field': companyField,
      'remarks': remarks,
      'additional_features': additionalFeatures,
      'status': status,
    };
  }
}
