import 'package:flutter/material.dart';
import '../services/premium_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  bool _shouldShowAd = true;

  @override
  void initState() {
    super.initState();
    _checkAdStatus();
  }

  Future<void> _checkAdStatus() async {
    final shouldShow = await PremiumService.shouldShowAds();
    setState(() => _shouldShowAd = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAd) {
      return const SizedBox();
    }

    // In real app: Use google_mobile_ads package
    // For MVP: Show placeholder banner
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Advertisement',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                // Navigate to premium
                Navigator.pushNamed(context, '/paywall');
              },
              child: const Text(
                'Remove ads with Premium',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
