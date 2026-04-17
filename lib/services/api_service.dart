import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/partner.dart';
import '../models/invoice.dart';

class ApiService {
  // Use 'localhost' or '127.0.0.1' if you are running the app on the Web or Windows.
  // Note: This will NOT work on an Android Emulator or Physical Device.
  static const String baseUrl = 'http://127.0.0.1/xpower_api';

  Future<Partner?> getPartner(int mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_partner.php?mobile_no=$mobileNo'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Partner.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  Future<bool> verifyOTP(int mobileNo, int otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_otp.php'),
        body: {
          'mobile_no': mobileNo.toString(),
          'otp_code': otpCode.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('API Error: $e');
    }
    return false;
  }

  Future<List<Invoice>> getInvoices(int mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_invoices.php?mobile_no=$mobileNo'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => Invoice.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('API Error: $e');
    }
    return [];
  }

  Future<bool> registerPartner(Partner partner) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register_partner.php'),
        body: {
          'first_name': partner.firstName,
          'last_name': partner.lastName,
          'mobile_no': partner.mobileNo.toString(),
          'email': partner.email,
          'bank_account_no': partner.bankAccountNo.toString(),
          'bank_name': partner.bankName,
          'bank_account_type': partner.bankAccountType,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('API Error: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> getDashboardData(int mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_dashboard_data.php?mobile_no=$mobileNo'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPayouts(int mobileNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_payouts.php?mobile_no=$mobileNo'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      print('API Error: $e');
    }
    return [];
  }
}
