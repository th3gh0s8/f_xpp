import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class MyCustomersPage extends StatefulWidget {
  final String phoneNumber;
  const MyCustomersPage({super.key, required this.phoneNumber});

  @override
  State<MyCustomersPage> createState() => _MyCustomersPageState();
}

class _MyCustomersPageState extends State<MyCustomersPage> {
  final ApiService _apiService = ApiService();
  List<Customer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    final customers = await _apiService.getCustomers(widget.phoneNumber);
    setState(() {
      _customers = customers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MY CUSTOMERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCustomers,
        color: Colors.black,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _customers.isEmpty 
            ? _buildEmptyState()
            : _buildCustomerList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: Colors.black.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Text('NO CUSTOMERS CREATED YET', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black38)),
            const SizedBox(height: 8),
            const Text('PULL DOWN TO REFRESH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: _customers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final client = _customers[index];
        bool isApproved = client.status == 'APPROVED';
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      client.companyName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.2),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      client.status,
                      style: TextStyle(
                        fontSize: 9, 
                        fontWeight: FontWeight.w900, 
                        color: isApproved ? Colors.green : Colors.orange
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailItem(Icons.location_on_outlined, client.companyAddress),
              _buildDetailItem(Icons.phone_android_outlined, client.companyNumber),
              _buildDetailItem(Icons.person_outline, client.adminName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
