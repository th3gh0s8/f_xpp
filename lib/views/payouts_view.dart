import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PayoutsView extends StatefulWidget {
  final String phoneNumber;
  const PayoutsView({super.key, required this.phoneNumber});

  @override
  State<PayoutsView> createState() => _PayoutsViewState();
}

class _PayoutsViewState extends State<PayoutsView> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _payouts = [];
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayoutData();
  }

  Future<void> _fetchPayoutData() async {
    final mobileNo = int.tryParse(widget.phoneNumber.replaceAll(RegExp(r'\D'), ''));
    if (mobileNo != null) {
      final payouts = await _apiService.getPayouts(mobileNo);
      final dashboard = await _apiService.getDashboardData(mobileNo);
      setState(() {
        _payouts = payouts;
        _dashboardData = dashboard;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PAYOUTS',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                const Text('AVAILABLE BALANCE', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  'LKR ${_dashboardData?['total_earned'] ?? '0.00'}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  onPressed: () {
                    // Implement payout request
                  },
                  child: const Text('REQUEST PAYOUT'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('HISTORY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),
          Expanded(
            child: _payouts.isEmpty 
              ? const Center(child: Text('NO PAYOUT HISTORY'))
              : ListView.builder(
                  itemCount: _payouts.length,
                  itemBuilder: (context, index) {
                    final payout = _payouts[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('PAYOUT #${payout['recipt_no']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${payout['request_date']}'),
                      trailing: Text(
                        'LKR ${payout['amount']}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    );
                  },
                ),
          )
        ],
      ),
    );
  }
}
