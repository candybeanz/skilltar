import 'package:flutter/material.dart';
import '../state/skilltar_store.dart';

class TopUpWalletScreen extends StatefulWidget {
  const TopUpWalletScreen({super.key});

  @override
  State<TopUpWalletScreen> createState() => _TopUpWalletScreenState();
}

class _TopUpWalletScreenState extends State<TopUpWalletScreen> {
  int? _selectedBundleIndex;

  final _bundles = const [
    _CreditBundle(
      title: 'Starter Pack',
      credits: 10,
      price: 20,
      savings: 0,
      isBestValue: false,
    ),
    _CreditBundle(
      title: 'Learner Bundle',
      credits: 55,
      price: 100,
      savings: 10,
      isBestValue: true,
    ),
    _CreditBundle(
      title: 'Pro Bundle',
      credits: 100,
      price: 180,
      savings: 20,
      isBestValue: false,
    ),
  ];

  void _purchaseBundle() {
    if (_selectedBundleIndex == null) return;

    final bundle = _bundles[_selectedBundleIndex!];
    
    // Add credits to user's wallet
    final store = SkilltarStore.I;
    store.credits.value = store.credits.value + bundle.credits;

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Purchase Successful!'),
          ],
        ),
        content: Text(
          '${bundle.credits} credits have been added to your wallet.\n\n'
          'Your new balance: ${store.credits.value} credits',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Profile
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedBundle = _selectedBundleIndex != null 
        ? _bundles[_selectedBundleIndex!] 
        : null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Top Up Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Credits do not expire',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Credit bundles
                  const Text(
                    'Select a bundle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ..._bundles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bundle = entry.value;
                    return _BundleCard(
                      bundle: bundle,
                      isSelected: _selectedBundleIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedBundleIndex = index;
                        });
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Payment method
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'VISA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Visa ending in 4242',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Expires 12/25',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit Payment Method - Coming Soon'),
                              ),
                            );
                          },
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom purchase button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedBundleIndex != null ? _purchaseBundle : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    selectedBundle != null
                        ? 'Purchase ${selectedBundle.credits} Credits'
                        : 'Select a bundle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditBundle {
  final String title;
  final int credits;
  final int price;
  final int savings;
  final bool isBestValue;

  const _CreditBundle({
    required this.title,
    required this.credits,
    required this.price,
    required this.savings,
    required this.isBestValue,
  });
}

class _BundleCard extends StatelessWidget {
  final _CreditBundle bundle;
  final bool isSelected;
  final VoidCallback onTap;

  const _BundleCard({
    required this.bundle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  bundle.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Credits
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${bundle.credits}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'credits',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price
                Row(
                  children: [
                    Text(
                      'SGD ${bundle.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (bundle.savings > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          'Save \$${bundle.savings.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // Best Value badge
            if (bundle.isBestValue)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade400,
                        Colors.orange.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            // Selection indicator
            if (isSelected)
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}