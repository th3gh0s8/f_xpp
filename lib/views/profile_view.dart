import 'package:flutter/material.dart';
import '../models/partner.dart';
import '../services/api_service.dart';
import 'edit_profile_page.dart';

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
    setState(() => _isLoading = true);
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
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSectionTitle('PERSONAL INFORMATION'),
          _buildInfoTile(Icons.person_outline, 'FULL NAME', '${_partner?.firstName} ${_partner?.lastName}'),
          _buildInfoTile(Icons.email_outlined, 'EMAIL ADDRESS', _partner?.email ?? '-'),
          _buildInfoTile(Icons.phone_android, 'MOBILE NUMBER', widget.phoneNumber),
          const SizedBox(height: 32),
          _buildSectionTitle('BANKING DETAILS'),
          _buildInfoTile(Icons.account_balance_outlined, 'BANK NAME', _partner?.bankName == '' ? 'NOT SET' : _partner?.bankName ?? 'NOT SET'),
          _buildInfoTile(Icons.numbers, 'ACCOUNT NUMBER', _partner?.bankAccountNo == 0 ? 'NOT SET' : _partner?.bankAccountNo.toString() ?? 'NOT SET'),
          _buildInfoTile(Icons. credit_card, 'ACCOUNT TYPE', _partner?.bankAccountType == '' ? 'NOT SET' : _partner?.bankAccountType ?? 'NOT SET'),
          const SizedBox(height: 48),
          _buildActionButton('EDIT PROFILE', Icons.edit, () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage(partner: _partner!)),
            );
            if (updated == true) _fetchPartnerData();
          }),
          const SizedBox(height: 12),
          _buildActionButton('LOGOUT', Icons.logout, () {
             Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: Colors.black),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_partner?.firstName} ${_partner?.lastName}'.toUpperCase(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const Text(
          'XPOWER PARTNER',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: Colors.black, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDestructive ? Colors.red : Colors.black,
          side: BorderSide(color: isDestructive ? Colors.red : Colors.black, width: 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }
}
