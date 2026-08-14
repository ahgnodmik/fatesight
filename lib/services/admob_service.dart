import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  // Test Ad Unit IDs (replace with your actual IDs for production)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';
  
  // Production Ad Unit IDs (replace with your actual IDs)
  static const String _productionBannerAdUnitId = 'ca-app-pub-8527804772343765/8943630725';
  static const String _productionInterstitialAdUnitId = 'ca-app-pub-8527804772343765/1234567890';
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
  
  static InterstitialAd? _interstitialAd;
  
  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }
  
  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('Interstitial ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('Interstitial ad dismissed');
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Interstitial ad failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
        },
      );
      _interstitialAd!.show();
    }
  }
  
  static void setTestMode(bool isTestMode) {
    _isTestMode = isTestMode;
  }
}
