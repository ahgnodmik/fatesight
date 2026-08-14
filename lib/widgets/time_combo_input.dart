import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeComboInput extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;
  final String label;
  final bool isKorean;
  final VoidCallback? onFieldFocus;

  const TimeComboInput({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
    required this.label,
    required this.isKorean,
    this.onFieldFocus,
  });

  @override
  State<TimeComboInput> createState() => _TimeComboInputState();
}

class _TimeComboInputState extends State<TimeComboInput> {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _hourController = TextEditingController(
      text: _selectedTime.hour.toString(),
    );
    _minuteController = TextEditingController(
      text: _selectedTime.minute.toString(),
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _updateTime() {
    try {
      final hour = int.parse(_hourController.text);
      final minute = int.parse(_minuteController.text);

      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        final newTime = TimeOfDay(hour: hour, minute: minute);
        setState(() {
          _selectedTime = newTime;
        });
        widget.onTimeChanged(newTime);
      }
    } catch (e) {
      // 잘못된 입력 무시
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _hourController.text = picked.hour.toString();
        _minuteController.text = picked.minute.toString();
      });
      widget.onTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),

        // 시간 입력 컨테이너
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // 시분 입력 필드들
              Row(
                children: [
                  // 시간 입력
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isKorean ? '시' : 'Hour',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Focus(
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              widget.onFieldFocus?.call();
                            }
                          },
                          child: TextFormField(
                            controller: _hourController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            onChanged: (value) => _updateTime(),
                            decoration: InputDecoration(
                              hintText: '14',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8B5CF6),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 콜론 표시
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 분 입력
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isKorean ? '분' : 'Minute',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Focus(
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              widget.onFieldFocus?.call();
                            }
                          },
                          child: TextFormField(
                            controller: _minuteController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            onChanged: (value) => _updateTime(),
                            decoration: InputDecoration(
                              hintText: '30',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8B5CF6),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 구분선
              Container(height: 1, color: const Color(0xFFE5E7EB)),

              const SizedBox(height: 12),

              // 시간 선택 버튼
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF8B5CF6),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isKorean
                            ? '시간 선택기에서 선택하기'
                            : 'Select from Time Picker',
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 현재 선택된 시간 표시
              Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
