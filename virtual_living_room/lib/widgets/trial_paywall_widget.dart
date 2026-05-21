import 'package:flutter/material.dart';

class TrialPaywallWidget extends StatelessWidget {
  final String upiId;
  final String whatsappSupport;

  const TrialPaywallWidget({
    super.key,
    required this.upiId,
    required this.whatsappSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Icon(Icons.workspace_premium, color: Colors.amber, size: 48)),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '👑 Premium Host Pass',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Guests can join and play for free. Hosting requires manual premium activation in this trial.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.35)),
            ),
            child: Text(
              '1) Pay via UPI: $upiId\n'
              '2) Take payment screenshot\n'
              '3) Send screenshot + mobile number to WhatsApp: $whatsappSupport\n'
              '4) Admin sets isPremiumHost=true after manual verification',
              style: const TextStyle(color: Colors.white90, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Disclaimer: Manual activations are reviewed and can be revoked for fraud or policy abuse.',
            style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
