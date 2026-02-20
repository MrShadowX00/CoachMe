// Stub implementation for web — AdMob not supported on web

class AdsService {
  static Future<void> initialize() async {}
  static void showInterstitial() {}
  static void showRewarded({required Function(dynamic) onRewarded}) {}
  static bool get isInterstitialReady => false;
  static bool get isRewardedReady => false;
  // createBanner returns null on web — BannerAdWidget handles this
  static dynamic createBanner() => null;
}
