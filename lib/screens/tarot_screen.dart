import 'package:flutter/material.dart';
import 'package:fatesight/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/zodiac_character_widget.dart';
import '../models/zodiac_character.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _fanAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _fanAnimation;
  
  bool _isCardRevealed = false;
  bool _isFanMode = true;
  Map<String, dynamic>? _selectedCard;
  String? _fortuneText;
  int _currentCardIndex = 0;
  double _dragOffset = 0.0;
  double _maxDragOffset = 0.0;
  bool _isCardSelected = false;
  int _previousCardIndex = 0;
  
  // 전체 타로 카드 수 (메이저+마이너 78장)
  final int _numTarotCards = 78;

  // 간단한 이모지 데코 목록
  static const List<String> _cardEmojis = [
    '🔮','⭐','🌙','✨','🌟','🔥','💫','🪄','🌓','☀️',
  ];

  String _emojiForIndex(int index) {
    return _cardEmojis[index % _cardEmojis.length];
  }

  // 타로카드 데이터
  final List<Map<String, dynamic>> _tarotCards = [
    {
      'name_ko': '더 풀(The Fool)',
      'name_en': 'The Fool',
      'meaning_ko': '새로운 시작, 순수함, 모험',
      'meaning_en': 'New beginnings, innocence, adventure',
      'fortune_ko': '오늘은 새로운 도전을 시작하기에 좋은 날입니다. 두려움 없이 앞으로 나아가세요.',
      'fortune_en': 'Today is a good day to start new challenges. Move forward without fear.',
      'color': Color(0xFF4F46E5), // 인디고
    },
    {
      'name_ko': '더 매지션(The Magician)',
      'name_en': 'The Magician',
      'meaning_ko': '의지력, 창조력, 집중력',
      'meaning_en': 'Willpower, creativity, concentration',
      'fortune_ko': '당신의 능력과 재능을 활용할 수 있는 기회가 찾아올 것입니다.',
      'fortune_en': 'An opportunity to utilize your abilities and talents will come.',
      'color': Color(0xFFDC2626), // 빨강
    },
    {
      'name_ko': '더 하이 프리스티스(The High Priestess)',
      'name_en': 'The High Priestess',
      'meaning_ko': '직감, 신비, 내면의 지혜',
      'meaning_en': 'Intuition, mystery, inner wisdom',
      'fortune_ko': '내면의 목소리에 귀 기울이세요. 직감이 중요한 결정을 도와줄 것입니다.',
      'fortune_en': 'Listen to your inner voice. Intuition will help with important decisions.',
      'color': Color(0xFF7C3AED), // 보라
    },
    {
      'name_ko': '더 엠프레스(The Empress)',
      'name_en': 'The Empress',
      'meaning_ko': '풍요, 창조성, 모성',
      'meaning_en': 'Abundance, creativity, motherhood',
      'fortune_ko': '창조적 활동과 풍요로운 결과를 기대할 수 있습니다.',
      'fortune_en': 'You can expect creative activities and abundant results.',
      'color': Color(0xFF059669), // 초록
    },
    {
      'name_ko': '더 엠퍼러(The Emperor)',
      'name_en': 'The Emperor',
      'meaning_ko': '권위, 안정, 리더십',
      'meaning_en': 'Authority, stability, leadership',
      'fortune_ko': '리더십을 발휘할 기회가 생길 것입니다. 확고한 의지로 목표를 달성하세요.',
      'fortune_en': 'An opportunity to demonstrate leadership will arise. Achieve your goals with firm determination.',
      'color': Color(0xFFD97706), // 주황
    },
    {
      'name_ko': '더 히어로판트(The Hierophant)',
      'name_en': 'The Hierophant',
      'meaning_ko': '전통, 지혜, 가르침',
      'meaning_en': 'Tradition, wisdom, teaching',
      'fortune_ko': '전통적인 방법이나 멘토의 조언이 도움이 될 것입니다.',
      'fortune_en': 'Traditional methods or mentor advice will be helpful.',
      'color': Color(0xFF0891B2), // 청록
    },
    {
      'name_ko': '더 러버스(The Lovers)',
      'name_en': 'The Lovers',
      'meaning_ko': '사랑, 선택, 조화',
      'meaning_en': 'Love, choice, harmony',
      'fortune_ko': '중요한 선택의 순간이 다가옵니다. 마음의 소리에 따라 결정하세요.',
      'fortune_en': 'An important moment of choice is approaching. Decide according to your heart.',
      'color': Color(0xFFEC4899), // 핑크
    },
    {
      'name_ko': '더 채리엇(The Chariot)',
      'name_en': 'The Chariot',
      'meaning_ko': '의지력, 승리, 통제',
      'meaning_en': 'Willpower, victory, control',
      'fortune_ko': '강한 의지력으로 목표를 달성할 수 있습니다. 포기하지 마세요.',
      'fortune_en': 'You can achieve your goals with strong willpower. Don\'t give up.',
      'color': Color(0xFF7C2D12), // 갈색
    },
    {
      'name_ko': '스트렝스(Strength)',
      'name_en': 'Strength',
      'meaning_ko': '내적 힘, 용기, 인내',
      'meaning_en': 'Inner strength, courage, patience',
      'fortune_ko': '어려운 상황에서도 내적 힘으로 극복할 수 있습니다.',
      'fortune_en': 'You can overcome difficult situations with inner strength.',
      'color': Color(0xFFB91C1C), // 진한 빨강
    },
    {
      'name_ko': '더 허밋(The Hermit)',
      'name_en': 'The Hermit',
      'meaning_ko': '성찰, 내적 탐구, 지혜',
      'meaning_en': 'Reflection, inner exploration, wisdom',
      'fortune_ko': '혼자만의 시간을 갖고 내면을 성찰해보세요. 중요한 깨달음이 있을 것입니다.',
      'fortune_en': 'Take time alone to reflect on your inner self. There will be important insights.',
      'color': Color(0xFF6B7280), // 회색
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _cardRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeIn,
    ));
    
    _fanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fanAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    // 최대 드래그 오프셋 계산 (카드 개수에 따라)
    _maxDragOffset = (_numTarotCards - 1) * 60.0;
    
    // 부채 애니메이션 시작
    _fanAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _textAnimationController.dispose();
    _fanAnimationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isCardRevealed) return;
    
    setState(() {
      _dragOffset = (_dragOffset - details.delta.dx).clamp(0.0, _maxDragOffset);
      final newCardIndex = (_dragOffset / 60.0).round().clamp(0, _numTarotCards - 1);
      
      // 카드 인덱스가 변경되었을 때
      if (newCardIndex != _currentCardIndex) {
        _previousCardIndex = _currentCardIndex;
        _currentCardIndex = newCardIndex;
        _isCardSelected = false; // 새로운 카드 선택 시 선택 상태 리셋
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isCardRevealed) return;
    
    // 스냅 효과
    final targetOffset = _currentCardIndex * 60.0;
    setState(() {
      _dragOffset = targetOffset;
    });
    
    // 카드 선택 인터랙션 - 햅틱 피드백
    // HapticFeedback.lightImpact();
    
    // 카드 이동 후 선택 애니메이션
    _animateCardSelection();
  }

  void _animateCardSelection() {
    // 카드 선택 하이라이트를 잠깐 주고 원상복귀
    setState(() {
      _isCardSelected = true;
    });

    _fanAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isCardSelected = false;
      });
    });
  }

  void _selectCurrentCard() {
    // 토글: 이미 펼쳐져 있으면 닫기
    if (_isCardRevealed) {
      setState(() {
        _isCardRevealed = false;
        _selectedCard = null;
        _isCardSelected = false;
      });
      return;
    }

    // 카드 해석 노출 (부채 모드 유지)
    setState(() {
      _selectedCard = _tarotCards[_currentCardIndex % _tarotCards.length];
      _isCardRevealed = true;
      _isCardSelected = true;
      _isFanMode = true;
    });

    // 텍스트 페이드인
    _textAnimationController.forward(from: 0);

    // 하이라이트는 잠시만 유지
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isCardSelected = false;
      });
    });
  }

  void _resetCard() {
    setState(() {
      _isCardRevealed = false;
      _isFanMode = true;
      _selectedCard = null;
      _fortuneText = null;
      _currentCardIndex = 0;
      _dragOffset = 0.0;
      _isCardSelected = false;
      _previousCardIndex = 0;
    });
    
    _cardAnimationController.reset();
    _textAnimationController.reset();
    _fanAnimationController.reset();
    
    // 부채 애니메이션 다시 시작
    _fanAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKorean = context.read<LanguageProvider>().locale.languageCode == 'ko';
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          l10n.tarotTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      color: Colors.white,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 12지신 캐릭터들
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ZodiacCharacters.characters.length,
                    itemBuilder: (context, index) {
                      final character = ZodiacCharacters.characters[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ZodiacCharacterWidget(
                          character: character,
                          size: 50,
                          showName: false,
                          animated: true,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // 타이틀
                Text(
                  l10n.dragToSelectCard,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // 카드 영역
                Expanded(
                  child: _isFanMode
                      ? _buildFanCards(context)
                      : Center(
                          child: AnimatedBuilder(
                            animation: _cardAnimationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _cardScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _cardRotationAnimation.value,
                                  child: Container(
                                    width: 200,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: _buildRevealedCard(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
                
                // 운세 텍스트
                if (_selectedCard != null)
                  AnimatedBuilder(
                    animation: _textFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isKorean ? _selectedCard!['name_ko'] : _selectedCard!['name_en'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isKorean ? _selectedCard!['meaning_ko'] : _selectedCard!['meaning_en'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isKorean ? _selectedCard!['fortune_ko'] : _selectedCard!['fortune_en'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                
                // 버튼들
                if (_isFanMode) ...[
                  // 부채 모드 버튼들
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      child: ElevatedButton.icon(
                        onPressed: _selectCurrentCard,
                        icon: Icon(
                          _isCardSelected ? Icons.visibility : Icons.auto_awesome,
                          size: 24,
                        ),
                        label: Text(
                          _isCardSelected 
                              ? l10n.checkFortune
                              : l10n.selectCard,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCardSelected 
                              ? const Color(0xFF10B981)
                              : const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: _isCardSelected 
                              ? const Color(0xFF10B981).withOpacity(0.4)
                              : const Color(0xFF8B5CF6).withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // 결과 화면 버튼들
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetCard,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.drawAgain),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.home),
                          label: Text(l10n.home),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFanCards(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: AnimatedBuilder(
        animation: _fanAnimation,
        builder: (context, child) {
          return GestureDetector(
            onPanUpdate: _onDragUpdate,
            onPanEnd: _onDragEnd,
            child: SizedBox(
              width: double.infinity,
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 배경 카드들 (중앙 카드 제외)
                  ...List.generate(_numTarotCards, (index) {
                    if (index == _currentCardIndex) return const SizedBox.shrink(); // 중앙 카드는 별도 처리
                    
                    final cardOffset = index * 60.0 - _dragOffset;
                    final distanceFromCenter = (cardOffset / 60.0).abs();
                    final scale = (1.0 - distanceFromCenter * 0.15).clamp(0.7, 0.9);
                    final rotation = (cardOffset / 60.0) * 0.08;
                    final opacity = (1.0 - distanceFromCenter * 0.4).clamp(0.4, 0.8);
                    
                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 100 + cardOffset,
                      child: Transform.scale(
                        scale: scale * _fanAnimation.value,
                        child: Transform.rotate(
                          angle: rotation * _fanAnimation.value,
                          child: Opacity(
                            opacity: opacity * _fanAnimation.value,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentCardIndex = index;
                                  _dragOffset = index * 60.0;
                                });
                              },
                              child: Container(
                                width: 200,
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // 배경 그라디언트
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF8B5CF6),
                                            Color(0xFF7C3AED),
                                            Color(0xFF6D28D9),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // 이모지 + 텍스트 데코
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _emojiForIndex(index),
                                            style: const TextStyle(
                                              fontSize: 36,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Tap',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // 중앙 카드 (최상위에 배치)
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 100,
                    child: Transform.scale(
                      scale: _fanAnimation.value,
                      child: GestureDetector(
                        onTap: () {
                          // 중앙 카드 선택 시 추가 인터랙션
                          _selectCurrentCard();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 200,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _isCardSelected 
                                    ? const Color(0xFF10B981).withOpacity(0.8)
                                    : const Color(0xFF8B5CF6).withOpacity(0.8),
                                blurRadius: _isCardSelected ? 40 : 35,
                                offset: const Offset(0, 15),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: _isCardSelected 
                                  ? Colors.white.withOpacity(1.0)
                                  : Colors.white.withOpacity(0.9),
                              width: _isCardSelected ? 5 : 4,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 배경 그라디언트
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _isCardSelected ? [
                                      const Color(0xFF10B981),
                                      const Color(0xFF059669),
                                      const Color(0xFF047857),
                                    ] : [
                                      const Color(0xFF8B5CF6),
                                      const Color(0xFF7C3AED),
                                      const Color(0xFF6D28D9),
                                    ],
                                  ),
                                ),
                              ),
                              // 이모지 + 텍스트 데코
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _emojiForIndex(_currentCardIndex),
                                      style: const TextStyle(
                                        fontSize: 42,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isCardSelected ? 'Ready' : 'Tap',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.95),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // 선택 인디케이터
                  if (_fanAnimation.value > 0.5)
                    Positioned(
                      bottom: 20,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isCardSelected ? [
                              const Color(0xFF10B981),
                              const Color(0xFF059669),
                            ] : [
                              const Color(0xFF8B5CF6),
                              const Color(0xFF7C3AED),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: _isCardSelected 
                                  ? const Color(0xFF10B981).withOpacity(0.4)
                                  : const Color(0xFF8B5CF6).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCardSelected ? Icons.check_circle : Icons.auto_awesome,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCardSelected
                                  ? l10n.cardSelection(_currentCardIndex + 1, _numTarotCards)
                                  : '${_currentCardIndex + 1} / $_numTarotCards',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildRevealedCard() {
    final cardColor = _selectedCard![
      'color'
    ] as Color;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColor.withOpacity(0.8),
            cardColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
