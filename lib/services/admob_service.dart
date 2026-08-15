import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  // Test Ad Unit IDs (replace with your actual IDs for production)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  // 보상형 전면광고 테스트 단위
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/5354046379';
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';

  // Production Ad Unit IDs (replace with your actual IDs)
  static const String _productionBannerAdUnitId = 'ca-app-pub-8527804772343765/8943630725';
  // 보상형 전면광고(rewarded interstitial) 형식 단위
  static const String _productionInterstitialAdUnitId = 'ca-app-pub-8527804772343765/8766250560';
  static const String _productionAppId = 'ca-app-pub-8527804772343765~6177603256';

  static bool _isInitialized = false;
  static bool _isTestMode = false;
  
  static String get bannerAdUnitId => _isTestMode ? _testBannerAdUnitId : _productionBannerAdUnitId;
  static String get interstitialAdUnitId => _isTestMode ? _testInterstitialAdUnitId : _productionInterstitialAdUnitId;
  static String get appId => _isTestMode ? _testAppId : _productionAppId;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('AdMob initialized successfully');
    } catch (e) {
      print('AdMob initialization failed: $e');
      // Continue without AdMob if initialization fails
    }
  }
  
  static BannerAd? createBannerAd() {
    if (!_isInitialized) {
      print('AdMob not initialized, cannot create banner ad');
      return null;
    }
    
    try {
      return BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('Banner ad loaded');
          },
          onAdFailedToLoad: (ad, error) {
            print('Banner ad failed to load: $error');
            ad.dispose();
          },
          onAdOpened: (ad) {
            print('Banner ad opened');
          },
          onAdClosed: (ad) {
            print('Banner ad closed');
          },
        ),
      );
    } catch (e) {
      print('Failed to create banner ad: $e');
      return null;
    }
  }
  
  static RewardedInterstitialAd? _interstitialAd;

  // 전면광고 최소 간격 — 연속 노출로 인한 이탈 방지.
  // 콘솔의 게재빈도 설정과 별개로 동작하는 클라이언트 하한선.
  static const Duration _interstitialCooldown = Duration(minutes: 3);
  static DateTime? _lastInterstitialShownAt;

  static void loadInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Rewarded interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('Rewarded interstitial ad failed to load: $error');
        },
      ),
    );
  }

  static void showInterstitialAd() {
    final last = _lastInterstitialShownAt;
    if (last != null && DateTime.now().difference(last) < _interstitialCooldown) {
      return;
    }
    if (_interstitialAd != null) {
      _lastInterstitialShownAt = DateTime.now();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('Rewarded interstitial ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('Rewarded interstitial ad dismissed');
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Rewarded interstitial ad failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
        },
      );
      // 보상형 전면 — 현재 앱은 보상 경제가 없어 리워드는 미사용
      _interstitialAd!.show(onUserEarnedReward: (ad, reward) {});
    }
  }
  
  static void setTestMode(bool isTestMode) {
    _isTestMode = isTestMode;
  }
}
