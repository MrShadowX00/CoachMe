import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static const _androidBanner       = 'ca-app-pub-7668896830420502/1581347698';
  static const _androidInterstitial = 'ca-app-pub-7668896830420502/7031725747';
  static const _androidRewarded     = 'ca-app-pub-7668896830420502/9396258533';
  static const _iosBanner           = 'ca-app-pub-7668896830420502/4255177725';
  static const _iosInterstitial     = 'ca-app-pub-7668896830420502/2511285986';
  static const _iosRewarded         = 'ca-app-pub-7668896830420502/2726473631';

  static String get bannerAdUnitId =>
      Platform.isAndroid ? _androidBanner : _iosBanner;
  static String get interstitialAdUnitId =>
      Platform.isAndroid ? _androidInterstitial : _iosInterstitial;
  static String get rewardedAdUnitId =>
      Platform.isAndroid ? _androidRewarded : _iosRewarded;

  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadInterstitial();
    loadRewarded();
  }

  static BannerAd createBanner() => BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );

  static void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _interstitialAd = null;
            loadInterstitial();
          });
        },
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  static void showInterstitial() => _interstitialAd?.show();

  static void loadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _rewardedAd = null;
            loadRewarded();
          });
        },
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  static void showRewarded({required Function(RewardItem) onRewarded}) =>
      _rewardedAd?.show(onUserEarnedReward: (_, r) => onRewarded(r));

  static bool get isInterstitialReady => _interstitialAd != null;
  static bool get isRewardedReady => _rewardedAd != null;
}
