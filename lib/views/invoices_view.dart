import 'package:flutter/material.dart';

class InvoicesView extends StatelessWidget {
  const InvoicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          _buildInvoicesList(),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
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
                    'INV-00${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('2023-10-27', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Text(
                'LKR 1,500.00',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        );
      },
    );
  }
}
