import 'package:flutter/material.dart';

class PayoutsView extends StatelessWidget {
  const PayoutsView({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Text('LKR 12,500.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  onPressed: () {},
                  child: const Text('REQUEST PAYOUT'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('HISTORY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('PAYOUT #${1024 - index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('2023-10-20'),
                trailing: const Text('LKR 5,000.00', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
