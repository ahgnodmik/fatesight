import 'package:flutter/material.dart';
import '../models/zodiac_character.dart';

class ZodiacCharacterWidget extends StatefulWidget {
  final ZodiacCharacter character;
  final double size;
  final bool showName;
  final bool animated;
  final VoidCallback? onTap;

  const ZodiacCharacterWidget({
    Key? key,
    required this.character,
    this.size = 80.0,
    this.showName = true,
    this.animated = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<ZodiacCharacterWidget> createState() => _ZodiacCharacterWidgetState();
}

class _ZodiacCharacterWidgetState extends State<ZodiacCharacterWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.animated) {
      _bounceController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );
      
      _glowController = AnimationController(
        duration: const Duration(milliseconds: 3000),
        vsync: this,
      );

      _bounceAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ));

      _glowAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ));

      _bounceController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _bounceController.dispose();
      _glowController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캐릭터 컨테이너
          AnimatedBuilder(
            animation: widget.animated ? _bounceAnimation : const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: widget.animated ? 0.9 + (_bounceAnimation.value * 0.1) : 1.0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.character.primaryColor.withOpacity(0.3),
                        widget.character.secondaryColor.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.character.primaryColor.withOpacity(0.3),
                        blurRadius: widget.animated ? 10 + (_glowAnimation.value * 5) : 10,
                        spreadRadius: widget.animated ? 2 + (_glowAnimation.value * 2) : 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 배경 원
                      Container(
                        width: widget.size * 0.8,
                        height: widget.size * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.9),
                          border: Border.all(
                            color: widget.character.primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      // 이모지
                      Text(
                        widget.character.emoji,
                        style: TextStyle(
                          fontSize: widget.size * 0.4,
                        ),
                      ),
                      // 반짝이는 효과
                      if (widget.animated)
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: widget.size * 0.1,
                              right: widget.size * 0.1,
                              child: Opacity(
                                opacity: _glowAnimation.value,
                                child: Container(
                                  width: widget.size * 0.15,
                                  height: widget.size * 0.15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.character.primaryColor,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
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
            },
          ),
          
          // 이름 표시
          if (widget.showName) ...[
            const SizedBox(height: 8),
            Text(
              widget.character.name,
              style: TextStyle(
                fontSize: widget.size * 0.15,
                fontWeight: FontWeight.w600,
                color: widget.character.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ZodiacCharacterGrid extends StatelessWidget {
  final Function(ZodiacCharacter)? onCharacterSelected;
  final bool showNames;
  final bool animated;

  const ZodiacCharacterGrid({
    Key? key,
    this.onCharacterSelected,
    this.showNames = true,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: ZodiacCharacters.characters.length,
      itemBuilder: (context, index) {
        final character = ZodiacCharacters.characters[index];
        return ZodiacCharacterWidget(
          character: character,
          size: 70,
          showName: showNames,
          animated: animated,
          onTap: () => onCharacterSelected?.call(character),
        );
      },
    );
  }
}

class ZodiacCharacterCarousel extends StatefulWidget {
  final Function(ZodiacCharacter)? onCharacterSelected;
  final bool showNames;
  final bool animated;

  const ZodiacCharacterCarousel({
    Key? key,
    this.onCharacterSelected,
    this.showNames = true,
    this.animated = true,
  }) : super(key: key);

  @override
  State<ZodiacCharacterCarousel> createState() => _ZodiacCharacterCarouselState();
}

class _ZodiacCharacterCarouselState extends State<ZodiacCharacterCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.3);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: ZodiacCharacters.characters.length,
            itemBuilder: (context, index) {
              final character = ZodiacCharacters.characters[index];
              final isSelected = index == _currentIndex;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Transform.scale(
                  scale: isSelected ? 1.1 : 0.9,
                  child: ZodiacCharacterWidget(
                    character: character,
                    size: isSelected ? 90 : 70,
                    showName: widget.showNames,
                    animated: widget.animated && isSelected,
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      widget.onCharacterSelected?.call(character);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        
        // 페이지 인디케이터
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            ZodiacCharacters.characters.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index 
                    ? ZodiacCharacters.characters[_currentIndex].primaryColor
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}








