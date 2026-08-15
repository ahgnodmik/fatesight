import 'package:flutter/material.dart';
import 'package:fatesight/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../widgets/date_combo_input.dart';
import '../widgets/time_combo_input.dart';

typedef FortuneFormResult = ({String name, DateTime birthDateTime});

class FortuneInputScreen extends StatefulWidget {
  const FortuneInputScreen({super.key});

  @override
  State<FortuneInputScreen> createState() => _FortuneInputScreenState();
}

class _FortuneInputScreenState extends State<FortuneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();
  final _nameFocusNode = FocusNode();
  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _dateFieldKey = GlobalKey();
  final GlobalKey _timeFieldKey = GlobalKey();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _nameFocusNode.addListener(
      () => _handleFocus(_nameFieldKey, _nameFocusNode),
    );
    _validateForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onTimeChanged(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final birthDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      Navigator.of(context).pop<FortuneFormResult>((
        name: _nameController.text.trim(),
        birthDateTime: birthDateTime,
      ));
    }
  }

  void _validateForm() {
    final isValid = _nameController.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _handleFocus(GlobalKey targetKey, FocusNode focusNode) {
    if (!focusNode.hasFocus) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensureVisible(targetKey),
    );
  }

  void _ensureVisible(GlobalKey targetKey) {
    final context = targetKey.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 250),
      alignment: 0.1,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKorean =
        context.read<LanguageProvider>().locale.languageCode == 'ko';
    final mediaQuery = MediaQuery.of(context);

    final bottomInset = mediaQuery.viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF6B7280),
            size: 24,
          ),
          tooltip: isKorean ? '메인화면으로 돌아가기' : 'Back to Main Screen',
        ),
        centerTitle: true,
        title: Text(
          isKorean ? '🔮 운명의 이야기' : '🔮 Fortune Story',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset + 72),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.enterName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          KeyedSubtree(
                            key: _nameFieldKey,
                            child: TextFormField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              onTap: () {
                                if (_nameController.text.isNotEmpty) {
                                  _nameController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _nameController.text.length,
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText: l10n.nameHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF8B5CF6),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return isKorean
                                      ? '이름을 입력해주세요'
                                      : 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          DateComboInput(
                            key: _dateFieldKey,
                            initialDate: _selectedDate,
                            onDateChanged: _onDateChanged,
                            label: l10n.birthDate,
                            isKorean: isKorean,
                            onFieldFocus: () => _ensureVisible(_dateFieldKey),
                          ),
                          const SizedBox(height: 20),
                          TimeComboInput(
                            key: _timeFieldKey,
                            initialTime: _selectedTime,
                            onTimeChanged: _onTimeChanged,
                            label: l10n.birthTime,
                            isKorean: isKorean,
                            onFieldFocus: () => _ensureVisible(_timeFieldKey),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      mediaQuery.viewPadding.bottom + 24,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFormValid ? _submitForm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.getFortuneStory,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
