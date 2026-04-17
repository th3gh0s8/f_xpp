import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';

class InvoicesView extends StatefulWidget {
  final String phoneNumber;
  const InvoicesView({super.key, required this.phoneNumber});

  @override
  State<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<InvoicesView> {
  final ApiService _apiService = ApiService();
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    final mobileNo = int.tryParse(widget.phoneNumber.replaceAll(RegExp(r'\D'), ''));
    if (mobileNo != null) {
      final invoices = await _apiService.getInvoices(mobileNo);
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

    return RefreshIndicator(
      onRefresh: _fetchInvoices,
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ALL INVOICES',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            const Text('TRACK YOUR SALES AND COMMISSIONS'),
            const SizedBox(height: 24),
            if (_invoices.isEmpty)
              const Center(child: Text('NO INVOICES FOUND'))
            else
              _buildInvoicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _invoices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invoice = _invoices[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INV-${invoice.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${invoice.date}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Text(
                'LKR ${invoice.comAmount}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        );
      },
    );
  }
}
