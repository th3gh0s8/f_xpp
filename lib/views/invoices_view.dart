import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';
import 'invoice_details_page.dart';
import '../widgets/system_overlay_wrapper.dart';
import '../utils/format_utils.dart';

class InvoicesView extends StatefulWidget {
  final String phoneNumber;
  final bool isActive;
  const InvoicesView({
    super.key,
    required this.phoneNumber,
    required this.isActive,
  });

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

  @override
  void reassemble() {
    super.reassemble();
    _fetchInvoices();
  }

  @override
  void didUpdateWidget(covariant InvoicesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchInvoices();
    }
  }

  Future<void> _fetchInvoices() async {
    if (!mounted) return;
    final mobileNo = widget.phoneNumber;
    final invoices = await _apiService.getInvoices(mobileNo);
    if (mounted) {
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const SystemOverlayWrapper(
        child: Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.black)),
        ),
      );

    return SystemOverlayWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          title: const Text(
            'ALL INVOICES',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
          automaticallyImplyLeading: false, // Prevent accidental back button
        ),
        body: RefreshIndicator(
          onRefresh: _fetchInvoices,
          color: Colors.black,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRACK YOUR SALES AND COMMISSIONS',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (_invoices.isEmpty)
                  const Center(child: Text('NO INVOICES FOUND'))
                else
                  _buildInvoicesList(),
              ],
            ),
          ),
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
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InvoiceDetailsPage(invoice: invoice),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INV-${invoice.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${invoice.date.toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withOpacity(0.3),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatUtils.formatCurrency(
                          invoice.comAmount.toDouble(),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'COMMISSION',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
