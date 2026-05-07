import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'otp_verification_page.dart';
import 'registration_page.dart';
import 'services/api_service.dart';
import 'services/session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _completePhoneNumber = '';
  String _selectedCountryCode = '94'; 
  String _phoneNumberOnly = '';
  bool _isLoading = false;
  String? _savedSession;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final session = await SessionManager.getSession();
    if (mounted) {
      setState(() {
        _savedSession = session;
      });
    }
  }

  Future<void> _clearSession() async {
    await SessionManager.clearSession();
    if (mounted) {
      setState(() {
        _savedSession = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SESSION CLEARED. YOU CAN NOW LOG IN FRESH.')),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_phoneNumberOnly.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER MOBILE NUMBER')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Remove all non-digits AND remove leading zero if present
      String mobileNo = _phoneNumberOnly.replaceAll(RegExp(r'\D'), '');
      if (mobileNo.startsWith('0')) {
        mobileNo = mobileNo.substring(1);
      }
      
      if (mobileNo.isEmpty) throw Exception('INVALID MOBILE NUMBER');

      // Check if partner exists
      print('DEBUG: Attempting login to: ${ApiService.baseUrl}/get_partner.php?mobile_no=$mobileNo');
      final partner = await _apiService.getPartner(mobileNo);
      print('DEBUG: Partner response: $partner');

      if (partner != null) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPVerificationPage(
                phoneNumber: _phoneNumberOnly,
                displayPhoneNumber: _completePhoneNumber
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('MOBILE NOT REGISTERED. PLEASE SIGN UP.')),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RegistrationPage(
                mobileNo: mobileNo, // Pass the cleaned number without leading zero
                countryCode: '+$_selectedCountryCode',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CONNECTION ERROR: CHECK YOUR INTERNET')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'WELCOME',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AUTHENTICATE TO CONTINUE',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.4),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                
                if (_savedSession != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'LOGGED IN AS: $_savedSession',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blue),
                          ),
                        ),
                        TextButton(
                          onPressed: _clearSession,
                          child: const Text('CLEAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 60),
                
                IntlPhoneField(
                  controller: _phoneController,
                  initialCountryCode: 'LK',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'MOBILE NUMBER',
                    labelStyle: TextStyle(
                      color: Colors.black.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                    hintText: '77 123 4567',
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.2),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
                    ),
                  ),
                  languageCode: "en",
                  onChanged: (phone) {
                    String number = phone.number;
                    if (number.startsWith('0')) {
                      number = number.substring(1);
                      _phoneController.value = _phoneController.value.copyWith(
                        text: number,
                        selection: TextSelection.collapsed(offset: number.length),
                      );
                    }
                    setState(() {
                      _completePhoneNumber = phone.countryCode + number;
                      _selectedCountryCode = phone.countryCode;
                      _phoneNumberOnly = number;
                    });
                  },
                  onCountryChanged: (country) {
                     setState(() {
                      _selectedCountryCode = country.dialCode;
                    });
                  },
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text(
                            'REQUEST ACCESS',
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'SECURE GLOBAL PARTNER AUTHENTICATION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
