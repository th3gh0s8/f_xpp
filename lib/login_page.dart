import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'otp_verification_page.dart';
import 'registration_page.dart';
import 'services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _completePhoneNumber = '';
  String _selectedCountryCode = '94'; // Default to Sri Lanka code
  String _phoneNumberOnly = '';
  bool _isLoading = false;

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
      final mobileNo = _phoneNumberOnly.replaceAll(RegExp(r'\D'), '');
      
      if (mobileNo.isEmpty) throw Exception('INVALID MOBILE NUMBER');

      // Check if partner exists
      final partner = await _apiService.getPartner(mobileNo);

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
                mobileNo: _phoneNumberOnly,
                countryCode: '+$_selectedCountryCode',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CONNECTION ERROR: MAKE SURE XAMPP IS RUNNING')),
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  setState(() {
                    _completePhoneNumber = phone.completeNumber;
                    _selectedCountryCode = phone.countryCode;
                    _phoneNumberOnly = phone.number;
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
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
