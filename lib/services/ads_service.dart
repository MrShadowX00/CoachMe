import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  // ─── Android IDs ───────────────────────────────────────────────
  // ignore: unused_field
  static const _androidAppId       = 'ca-app-pub-7668896830420502~4938138778';
  static const _androidBanner      = 'ca-app-pub-7668896830420502/1581347698';
  static const _androidInterstitial= 'ca-app-pub-7668896830420502/7031725747';
  static const _androidRewarded    = 'ca-app-pub-7668896830420502/9396258533';

  // ─── iOS IDs ───────────────────────────────────────────────────
  // ignore: unused_field
  static const _iosAppId           = 'ca-app-pub-7668896830420502~7763612660';
  static const _iosBanner          = 'ca-app-pub-7668896830420502/4255177725';
  static const _iosInterstitial    = 'ca-app-pub-7668896830420502/2511285986';
  static const _iosRewarded        = 'ca-app-pub-7668896830420502/2726473631';

  // ─── Active IDs (platform-aware) ───────────────────────────────
  static String get bannerAdUnitId =>
      Platform.isAndroid ? _androidBanner : _iosBanner;

  static String get interstitialAdUnitId =>
      Platform.isAndroid ? _androidInterstitial : _iosInterstitial;

  static String get rewardedAdUnitId =>
      Platform.isAndroid ? _androidRewarded : _iosRewarded;

  // ─── State ─────────────────────────────────────────────────────
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static bool _initialized = false;

  // ─── Init ──────────────────────────────────────────────────────
  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    loadInterstitial();
    loadRewarded();
  }

  // ─── Banner ────────────────────────────────────────────────────
  static BannerAd createBanner() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  // ─── Interstitial ──────────────────────────────────────────────
  static void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial(); // reload for next time
            },
          );
        },
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  static void showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  // ─── Rewarded ──────────────────────────────────────────────────
  static void loadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  static void showRewarded({required Function(RewardItem reward) onRewarded}) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (_, reward) => onRewarded(reward));
    }
  }

  static bool get isInterstitialReady => _interstitialAd != null;
  static bool get isRewardedReady => _rewardedAd != null;
}
