import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fatesight/l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../services/admob_service.dart';
import '../services/saju_service.dart';
import '../services/saju_interpretation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/result_display.dart';
import '../widgets/zodiac_character_widget.dart';
import '../models/zodiac_character.dart';
import 'tarot_screen.dart';
import 'character_screen.dart';
import 'fortune_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _showResult = false;
  bool _isLoading = false;
  String _result = '';
  final SajuService _sajuService = SajuService();
  final SajuInterpretation _sajuInterpretation = SajuInterpretation();
  List<Map<String, dynamic>> _storyHistory = [];
  ZodiacCharacter? _userCharacter;

  static const _historyPrefsKey = 'story_history_v1';

  @override
  void initState() {
    super.initState();
    _bannerAd = AdMobService.createBannerAd();
    if (_bannerAd != null) {
      _bannerAd!.load();
    }
    AdMobService.loadInterstitialAd();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyPrefsKey);
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _storyHistory = [
          {
            'name': data['name'] as String,
            'birthDateTime': DateTime.parse(data['birthDateTime'] as String),
            'result': data['result'] as String,
            'timestamp': DateTime.parse(data['timestamp'] as String),
          },
        ];
      });
    } catch (_) {
      // 손상된 저장값은 무시하고 빈 히스토리로 시작
    }
  }

  Future<void> _saveHistory(Map<String, dynamic> story) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyPrefsKey,
      jsonEncode({
        'name': story['name'],
        'birthDateTime': (story['birthDateTime'] as DateTime).toIso8601String(),
        'result': story['result'],
        'timestamp': (story['timestamp'] as DateTime).toIso8601String(),
      }),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _onFormSubmitted(String name, DateTime birthDateTime) async {
    setState(() {
      _isLoading = true;
      _showResult = false;
      _result = '';
    });

    try {
      final languageProvider = context.read<LanguageProvider>();
      final language = languageProvider.locale.languageCode;

      // 생년월일로 12지신 캐릭터 결정
      final userCharacter = ZodiacCharacters.getCharacterByYear(
        birthDateTime.year,
      );

      final saju = _sajuService.calculate(birthDateTime);
      final result = await _sajuInterpretation.buildReading(
        name: name,
        saju: saju,
        language: language,
      );

      setState(() {
        _showResult = true;
        _result = result;
        _isLoading = false;
        _userCharacter = userCharacter;

        // 스토리 이력에 추가 (최대 1개만 유지)
        _storyHistory.clear();
        _storyHistory.add({
          'name': name,
          'birthDateTime': birthDateTime,
          'result': result,
          'timestamp': DateTime.now(),
        });
      });
      _saveHistory(_storyHistory.first);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showResult = true;
        _result = _getErrorMessage(
          context.read<LanguageProvider>().locale.languageCode,
        );
      });
    }
  }

  void _onBackToForm() {
    setState(() {
      _showResult = false;
      _result = '';
      _userCharacter = null;
    });
    // 리딩을 다 본 뒤가 자연스러운 광고 시점 — 로드 실패 시 조용히 건너뜀
    AdMobService.showInterstitialAd();
  }

  Future<void> _openFortuneInput() async {
    final result = await Navigator.of(context).push<FortuneFormResult>(
      MaterialPageRoute(
        builder: (_) => const FortuneInputScreen(),
        fullscreenDialog: true,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    await _onFormSubmitted(result.name, result.birthDateTime);
  }

  String _getErrorMessage(String language) {
    return language == 'ko'
        ? '❌ 오류가 발생했습니다\n\n사주를 계산하는 중 문제가 생겼습니다. 입력한 생년월일시를 확인하고 다시 시도해주세요.'
        : '❌ An error occurred\n\nSomething went wrong while calculating your reading. Please check your birth date and time, then try again.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      // 결과 화면에서 시스템 뒤로가기 시 앱 종료 대신 홈으로 복귀
      canPop: !_showResult,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showResult) _onBackToForm();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFAFAFA),
        body: Column(
          children: [
            // 상단 서비스 안내 배너 - 분석 중이거나 결과 화면일 때는 숨김
            if (!_isLoading && !_showResult) _buildServiceBanner(),

            // 스토리 이력 (1개만) - 서비스 배너 아래에 표시
            if (_storyHistory.isNotEmpty && !_showResult && !_isLoading)
              _buildStoryHistory(),

            // 메인 콘텐츠
            Expanded(
              child:
                  _isLoading
                      ? _buildLoadingWidget()
                      : _showResult
                      ? ResultDisplay(
                        result: _result,
                        onBack: _onBackToForm,
                        userCharacter: _userCharacter,
                      )
                      : _buildWelcomeScreen(),
            ),

            // 하단 광고 배너 (시스템 내비게이션 영역 침범 방지)
            if (_bannerAd != null)
              SafeArea(
                top: false,
                child: Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  color: Colors.white,
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.appTitle,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          actions: [
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                final currentLanguage = languageProvider.locale.languageCode;
                final displayText = currentLanguage == 'ko' ? 'KR' : 'EN';

                return GestureDetector(
                  onTap: () {
                    languageProvider.toggleLanguage();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    final l10n = AppLocalizations.of(context)!;
    final isKorean =
        context.read<LanguageProvider>().locale.languageCode == 'ko';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_stories,
                    size: 64,
                    color: Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isKorean
                        ? '🔮 운명의 이야기에 오신 것을 환영합니다'
                        : '🔮 Welcome to Fortune Stories',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isKorean
                        ? '위의 "이야기 들으러 가기" 버튼을 눌러\n개인화된 운명의 이야기를 시작해보세요.'
                        : 'Click the "Listen to Stories" button above\nto begin your personalized fortune story.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBanner() {
    final l10n = AppLocalizations.of(context)!;
    final isKorean =
        context.read<LanguageProvider>().locale.languageCode == 'ko';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 12지신 캐릭터들
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ZodiacCharacters.characters.length,
              itemBuilder: (context, index) {
                final character = ZodiacCharacters.characters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ZodiacCharacterWidget(
                    character: character,
                    size: 60,
                    showName: false,
                    animated: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.auto_stories, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🔮 ${l10n.fortuneStory}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.serviceDescription,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // 버튼들
          Column(
            children: [
              // 첫 번째 행 - 이야기 듣기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openFortuneInput,
                  icon: const Icon(Icons.play_arrow, color: Color(0xFF8B5CF6)),
                  label: Text(
                    l10n.listenToStories,
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 두 번째 행 - 12지신과 타로카드 버튼
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CharacterScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.pets, color: Colors.white),
                      label: Text(
                        isKorean ? '🐾 12지신' : '🐾 Zodiac',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TarotScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: Text(
                        isKorean ? '🔮 타로카드' : '🔮 Tarot',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryHistory() {
    if (_storyHistory.isEmpty) return const SizedBox.shrink();

    final story = _storyHistory.first;
    final l10n = AppLocalizations.of(context)!;
    final isKorean =
        context.read<LanguageProvider>().locale.languageCode == 'ko';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.recentStory,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${story['name']} • ${_formatDate(story['birthDateTime'])}',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showResult = true;
                  _result = story['result'];
                });
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: Text(l10n.viewAgain, style: const TextStyle(fontSize: 14)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                side: const BorderSide(color: Color(0xFF8B5CF6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildLoadingWidget() {
    final l10n = AppLocalizations.of(context)!;
    final isKorean =
        context.read<LanguageProvider>().locale.languageCode == 'ko';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.analyzingDestiny,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.pleaseWait,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
