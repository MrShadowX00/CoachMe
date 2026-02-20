import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_service_mobile.dart';
import '../theme/app_theme.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _banner = AdsService.createBanner()
      ..load().then((_) {
        if (mounted) setState(() => _loaded = true);
      });
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) return const SizedBox(height: 50);
    return Container(
      height: 50,
      color: AppTheme.card,
      child: AdWidget(ad: _banner!),
    );
  }
}
