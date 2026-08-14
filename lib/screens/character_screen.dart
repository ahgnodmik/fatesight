import 'package:flutter/material.dart';
import 'package:fatesight/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/zodiac_character.dart';
import '../widgets/zodiac_character_widget.dart';
import '../providers/language_provider.dart';

class CharacterScreen extends StatefulWidget {
  final ZodiacCharacter? selectedCharacter;

  const CharacterScreen({
    super.key,
    this.selectedCharacter,
  });

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ZodiacCharacter? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCharacter = widget.selectedCharacter;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKorean = context.read<LanguageProvider>().locale.languageCode == 'ko';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isKorean ? '12지신 캐릭터' : '12 Zodiac Characters',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF6B7280),
            size: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8B5CF6),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF8B5CF6),
          tabs: [
            Tab(
              text: isKorean ? '캐릭터 선택' : 'Select Character',
            ),
            Tab(
              text: isKorean ? '상세 정보' : 'Details',
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCharacterSelectionTab(),
            _buildCharacterDetailsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSelectionTab() {
    final isKorean = context.read<LanguageProvider>().locale.languageCode == 'ko';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
                Text(
                  isKorean ? '🌟 12지신 캐릭터를 선택해보세요' : '🌟 Choose Your Zodiac Character',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isKorean 
                    ? '각 캐릭터를 터치하면 상세한 정보를 볼 수 있습니다'
                    : 'Tap on any character to see detailed information',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 캐릭터 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: ZodiacCharacters.characters.length,
            itemBuilder: (context, index) {
              final character = ZodiacCharacters.characters[index];
              final isSelected = _selectedCharacter?.name == character.name;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCharacter = character;
                  });
                  _tabController.animateTo(1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                        ? character.primaryColor 
                        : const Color(0xFFE5E7EB),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                          ? character.primaryColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ZodiacCharacterWidget(
                        character: character,
                        size: 60,
                        showName: false,
                        animated: isSelected,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        character.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                            ? character.primaryColor 
                            : const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        character.englishName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected 
                            ? character.primaryColor.withOpacity(0.7)
                            : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterDetailsTab() {
    final isKorean = context.read<LanguageProvider>().locale.languageCode == 'ko';

    if (_selectedCharacter == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 64,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            Text(
              isKorean 
                ? '캐릭터를 선택해주세요' 
                : 'Please select a character',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isKorean 
                ? '첫 번째 탭에서 캐릭터를 선택하면\n상세 정보를 볼 수 있습니다'
                : 'Select a character from the first tab\nto view detailed information',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    final character = _selectedCharacter!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 캐릭터 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [character.primaryColor, character.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: character.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                ZodiacCharacterWidget(
                  character: character,
                  size: 100,
                  showName: false,
                  animated: true,
                ),
                const SizedBox(height: 16),
                Text(
                  character.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  character.englishName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  character.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 성격 정보
          _buildInfoCard(
            title: isKorean ? '성격' : 'Personality',
            icon: Icons.psychology,
            content: character.personality,
            color: character.primaryColor,
          ),
          
          const SizedBox(height: 16),
          
          // 운세 정보
          _buildInfoCard(
            title: isKorean ? '운세' : 'Fortune',
            icon: Icons.auto_awesome,
            content: character.fortune,
            color: character.primaryColor,
          ),
          
          const SizedBox(height: 16),
          
          // 궁합 정보
          _buildInfoCard(
            title: isKorean ? '궁합' : 'Compatibility',
            icon: Icons.favorite,
            content: character.compatibility,
            color: character.primaryColor,
          ),
          
          const SizedBox(height: 16),
          
          // 행운의 요소들
          _buildLuckyElementsCard(character, isKorean),
          
          const SizedBox(height: 16),
          
          // 특성들
          _buildTraitsCard(character, isKorean),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1F2937),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyElementsCard(ZodiacCharacter character, bool isKorean) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: character.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isKorean ? '행운의 요소' : 'Lucky Elements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: character.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 행운의 숫자
          _buildLuckyItem(
            isKorean ? '행운의 숫자' : 'Lucky Numbers',
            character.luckyNumbers,
            Icons.numbers,
            character.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          // 행운의 색깔
          _buildLuckyItem(
            isKorean ? '행운의 색깔' : 'Lucky Colors',
            character.luckyColors,
            Icons.palette,
            character.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          // 행운의 방향
          _buildLuckyItem(
            isKorean ? '행운의 방향' : 'Lucky Directions',
            character.luckyDirections,
            Icons.explore,
            character.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          // 오행
          _buildLuckyItem(
            isKorean ? '오행' : 'Element',
            character.element,
            Icons.water_drop,
            character.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          // 계절
          _buildLuckyItem(
            isKorean ? '계절' : 'Season',
            character.season,
            Icons.wb_sunny,
            character.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          // 시간대
          _buildLuckyItem(
            isKorean ? '시간대' : 'Time Range',
            character.timeRange,
            Icons.access_time,
            character.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTraitsCard(ZodiacCharacter character, bool isKorean) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: character.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isKorean ? '특성' : 'Traits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: character.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 기본 특성
          _buildTraitSection(
            isKorean ? '기본 특성' : 'Basic Traits',
            character.traits,
            character.primaryColor,
          ),
          
          const SizedBox(height: 16),
          
          // 장점
          _buildTraitSection(
            isKorean ? '장점' : 'Strengths',
            character.strengths,
            const Color(0xFF059669),
          ),
          
          const SizedBox(height: 16),
          
          // 단점
          _buildTraitSection(
            isKorean ? '단점' : 'Weaknesses',
            character.weaknesses,
            const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitSection(String title, List<String> traits, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: traits.map((trait) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                trait,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
