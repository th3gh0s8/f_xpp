import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardView extends StatefulWidget {
  final String phoneNumber;
  const DashboardView({super.key, required this.phoneNumber});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _recentInvoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mobileNo = int.tryParse(widget.phoneNumber.replaceAll(RegExp(r'\D'), ''));
    if (mobileNo != null) {
      final data = await _apiService.getDashboardData(mobileNo);
      final invoices = await _apiService.getInvoices(mobileNo);
      setState(() {
        _dashboardData = data;
        _recentInvoices = invoices;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 32),
            _buildStatsGrid(),
            const SizedBox(height: 40),
            const Text(
              'RECENT ACTIVITY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
            ),
            const SizedBox(height: 16),
            _buildInvoicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK,',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black.withOpacity(0.4)),
        ),
        const SizedBox(height: 4),
        Text(
          widget.phoneNumber,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'TOTAL EARNED', 
          'LKR ${_dashboardData?['total_earned'] ?? '0.00'}',
          [const Color(0xFF424242), const Color(0xFF212121)],
          Colors.white,
        ),
        _buildStatCard(
          'PENDING', 
          'LKR ${_dashboardData?['pending_payouts'] ?? '0.00'}',
          [const Color(0xFF757575), const Color(0xFF424242)],
          Colors.white,
        ),
        _buildStatCard(
          'LEVEL', 
          _dashboardData?['level'] ?? 'LEVEL 1',
          [const Color(0xFF757575), const Color(0xFF424242)],
          Colors.white,
        ),
        _buildStatCard(
          'INVOICES', 
          '${_dashboardData?['total_invoices'] ?? 0}',
          [const Color(0xFF424242), const Color(0xFF212121)],
          Colors.white,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, List<Color> colors, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: 9, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 0.5, 
              color: textColor.withOpacity(0.5)
            )
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value, 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w900, 
                color: textColor,
                letterSpacing: -0.5
              )
            )
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    if (_recentInvoices.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('NO RECENT ACTIVITY')));
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentInvoices.length > 5 ? 5 : _recentInvoices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invoice = _recentInvoices[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INV-${invoice.id}', 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${invoice.date}', 
                    style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w700)
                  ),
                ],
              ),
              Text(
                'LKR ${invoice.comAmount}', 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5)
              ),
            ],
          ),
        );
      },
    );
  }
}
