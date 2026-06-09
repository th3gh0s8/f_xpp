class ResellPackage {
  final int id;
  final String packageCode;
  final String packageName;
  final String description;
  final String additionalRemarks;
  final String currencyName;
  final double packageAmount;
  final String billingType;
  final int allowedUsers;
  final String status;
  final List<ResellPackageModule> modules;

  ResellPackage({
    required this.id,
    required this.packageCode,
    required this.packageName,
    required this.description,
    required this.additionalRemarks,
    required this.currencyName,
    required this.packageAmount,
    required this.billingType,
    required this.allowedUsers,
    required this.status,
    required this.modules,
  });

  Map<String, dynamic> toJson() => {
        'ID': id,
        'package_code': packageCode,
        'package_name': packageName,
        'description': description,
        'additional_remarks': additionalRemarks,
        'currency_name': currencyName,
        'package_amount': packageAmount,
        'billingType': billingType,
        'allowed_users': allowedUsers,
        'status': status,
        'modules': modules.map((m) => m.toJson()).toList(),
      };

  factory ResellPackage.fromJson(Map<String, dynamic> json) {
    return ResellPackage(
      id: int.tryParse(json['ID'].toString()) ?? 0,
      packageCode: json['package_code'] ?? '',
      packageName: json['package_name'] ?? '',
      description: json['description'] ?? '',
      additionalRemarks: json['additional_remarks'] ?? '',
      currencyName: json['currency_name'] ?? '',
      packageAmount: double.tryParse(json['package_amount'].toString()) ?? 0.0,
      billingType: json['billingType'] ?? '',
      allowedUsers: int.tryParse(json['allowed_users'].toString()) ?? 0,
      status: json['status'] ?? '',
      modules: (json['modules'] as List?)
              ?.map((m) => ResellPackageModule.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class ResellPackageModule {
  final int id;
  final int packageId;
  final String moduleName;
  final String currencyName;
  final double modulePrice;
  final String moduleDescription;
  final String moduleType;
  final String status;
  final String moduleGroup;

  ResellPackageModule({
    required this.id,
    required this.packageId,
    required this.moduleName,
    required this.currencyName,
    required this.modulePrice,
    required this.moduleDescription,
    required this.moduleType,
    required this.status,
    required this.moduleGroup,
  });

  Map<String, dynamic> toJson() => {
        'ID': id,
        'packageID': packageId,
        'module_name': moduleName,
        'currency_name': currencyName,
        'modulePrice': modulePrice,
        'module_description': moduleDescription,
        'moduleType': moduleType,
        'status': status,
        'module_group': moduleGroup,
      };

  factory ResellPackageModule.fromJson(Map<String, dynamic> json) {
    return ResellPackageModule(
      id: int.tryParse(json['ID'].toString()) ?? 0,
      packageId: int.tryParse(json['packageID'].toString()) ?? 0,
      moduleName: json['module_name'] ?? '',
      currencyName: json['currency_name'] ?? '',
      modulePrice: double.tryParse(json['modulePrice'].toString()) ?? 0.0,
      moduleDescription: json['module_description'] ?? '',
      moduleType: json['moduleType'] ?? '',
      status: json['status'] ?? '',
      moduleGroup: json['module_group'] ?? '',
    );
  }
}
