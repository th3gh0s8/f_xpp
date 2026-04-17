import 'package:flutter/material.dart';
import '../models/partner.dart';
import '../services/api_service.dart';

class ProfileView extends StatefulWidget {
  final String phoneNumber;
  const ProfileView({super.key, required this.phoneNumber});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ApiService _apiService = ApiService();
  Partner? _partner;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPartnerData();
  }

  Future<void> _fetchPartnerData() async {
    try {
      final mobileNo = int.tryParse(widget.phoneNumber.replaceAll(RegExp(r'\D'), ''));
      if (mobileNo != null) {
        final partner = await _apiService.getPartner(mobileNo);
        setState(() {
          _partner = partner;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (_partner == null) {
      return const Center(child: Text('FAILED TO LOAD PROFILE DATA'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            '${_partner!.firstName.toUpperCase()} ${_partner!.lastName.toUpperCase()}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          Text(
            'MOBILE: ${_partner!.mobileNo}',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildProfileItem(Icons.email, 'EMAIL ADDRESS', _partner!.email.toUpperCase()),
          _buildProfileItem(Icons.account_balance, 'BANK NAME', _partner!.bankName.toUpperCase()),
          _buildProfileItem(Icons.numbers, 'ACCOUNT NUMBER', _partner!.bankAccountNo.toString()),
          _buildProfileItem(Icons.credit_card, 'ACCOUNT TYPE', _partner!.bankAccountType.toUpperCase()),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Future implementation: Edit Profile
              },
              child: const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text(
                'LOGOUT',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
