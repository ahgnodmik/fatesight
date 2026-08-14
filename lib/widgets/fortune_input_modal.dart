import 'package:flutter/material.dart';
import 'package:fatesight/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'date_combo_input.dart';
import 'time_combo_input.dart';

class FortuneInputModal extends StatefulWidget {
  final Function(String name, DateTime birthDateTime, String question) onSubmit;
  final VoidCallback onClose;

  const FortuneInputModal({
    super.key,
    required this.onSubmit,
    required this.onClose,
  });

  @override
  State<FortuneInputModal> createState() => _FortuneInputModalState();
}

class _FortuneInputModalState extends State<FortuneInputModal>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  late final AnimationController _anim;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(duration: const Duration(milliseconds: 280), vsync: this)..forward();
    _slide = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    _nameController.dispose();
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDateChanged(DateTime date) => setState(() => _selectedDate = date);
  void _onTimeChanged(TimeOfDay time) => setState(() => _selectedTime = time);

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final birthDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      widget.onSubmit(
        _nameController.text.trim(),
        birthDateTime,
        _questionController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKorean = context.read<LanguageProvider>().locale.languageCode == 'ko';

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Stack(
          children: [
            // Dim backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  await _anim.reverse();
                  widget.onClose();
                },
                child: Opacity(
                  opacity: 0.5 * _fade.value,
                  child: const ColoredBox(color: Colors.black),
                ),
              ),
            ),

            // Bottom sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, MediaQuery.of(context).size.height * 0.3 * _slide.value),
                child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle & Header
                          const SizedBox(height: 10),
                          Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await _anim.reverse();
                                    widget.onClose();
                                  },
                                  icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7280), size: 24),
                                  tooltip: isKorean ? '메인화면으로 돌아가기' : 'Back to Main Screen',
                                ),
                                Expanded(
                                  child: Text(
                                    isKorean ? '🔮 운명의 이야기' : '🔮 Fortune Story',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),

                          // Scrollable form
                          // 스크롤 영역 + 하단 고정 버튼을 Stack으로 분리
                          Expanded(
                            child: Stack(
                              children: [
                                // Scrollable form content
                                SingleChildScrollView(
                                  controller: _scrollController,
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset + 72),
                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                    // Name
                                    Text(
                                      l10n.enterName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (fieldContext) => TextFormField(
                                        controller: _nameController,
                                        onTap: () {
                                          if (_nameController.text.isNotEmpty) _nameController.clear();
                                          // Ensure field is visible above the fixed button
                                          Future.delayed(const Duration(milliseconds: 50), () {
                                            Scrollable.ensureVisible(
                                              fieldContext,
                                              duration: const Duration(milliseconds: 250),
                                              alignment: 0.1,
                                            );
                                          });
                                        },
                                      decoration: InputDecoration(
                                        hintText: isKorean ? '이름을 입력해주세요' : 'Enter your name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? (isKorean ? '이름을 입력해주세요' : 'Please enter your name')
                                          : null,
                                    ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Birth date
                                    DateComboInput(
                                      initialDate: _selectedDate,
                                      onDateChanged: _onDateChanged,
                                      label: l10n.birthDate,
                                      isKorean: isKorean,
                                    ),
                                    const SizedBox(height: 20),

                                    // Birth time
                                    TimeComboInput(
                                      initialTime: _selectedTime,
                                      onTimeChanged: _onTimeChanged,
                                      label: l10n.birthTime,
                                      isKorean: isKorean,
                                    ),
                                    const SizedBox(height: 20),

                                    // Question
                                    Text(
                                      l10n.question,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (fieldContext) => TextFormField(
                                        controller: _questionController,
                                        onTap: () {
                                          if (_questionController.text.isNotEmpty) _questionController.clear();
                                          Future.delayed(const Duration(milliseconds: 50), () {
                                            Scrollable.ensureVisible(
                                              fieldContext,
                                              duration: const Duration(milliseconds: 250),
                                              alignment: 0.1,
                                            );
                                          });
                                        },
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: l10n.questionHint,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? (isKorean ? '궁금한 것을 입력해주세요' : 'Please enter your question')
                                          : null,
                                    ),
                                    ),
                                  ],
                                ),
                              ),
                                // Fixed bottom submit button (never moves)
                                Positioned(
                                  left: 20,
                                  right: 20,
                                  bottom: 20,
                                  child: SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF8B5CF6),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        l10n.getFortuneStory,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                    ),
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
          ],
        );
      },
    );
  }
}


