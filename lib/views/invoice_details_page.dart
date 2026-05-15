import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../utils/format_utils.dart';
import 'package:intl/intl.dart';

class InvoiceDetailsPage extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'INV-${invoice.id}',
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 32),
            _buildInfoSection(
              'CUSTOMER INFORMATION',
              [
                _buildDetailRow('NAME', invoice.cusName.toUpperCase()),
                _buildDetailRow('CODE', invoice.cusCode.toString()),
                _buildDetailRow('DB ID', invoice.cusTb.toString()),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              'TRANSACTION DETAILS',
              [
                _buildDetailRow('DATE', DateFormat('yyyy-MM-dd').format(invoice.date)),
                _buildDetailRow('TIME', invoice.time),
                _buildDetailRow('TOTAL VALUE', FormatUtils.formatCurrency(invoice.value.toDouble())),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              'PAYMENT STATUS',
              [
                _buildDetailRow('PAID AMOUNT', FormatUtils.formatCurrency(invoice.paid.toDouble())),
                _buildDetailRow('BALANCE', FormatUtils.formatCurrency(invoice.balance.toDouble()), valueColor: invoice.balance > 0 ? Colors.red : Colors.black),
              ],
            ),
            const SizedBox(height: 32),
            _buildCommissionCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    bool isFullyPaid = invoice.balance <= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFullyPaid ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isFullyPaid ? 'FULLY PAID' : 'PARTIAL PAYMENT',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'TOTAL COMMISSION EARNED',
            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            FormatUtils.formatCurrency(invoice.comAmount.toDouble()),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
        ],
      ),
    );
  }
// ... rest of file

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black38),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: valueColor ?? Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMMISSION VERIFIED',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  '${invoice.comPres}% Rate Applied',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
