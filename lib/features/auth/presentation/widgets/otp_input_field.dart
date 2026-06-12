import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool enabled;
  final String? initialValue;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.hasError = false,
    this.enabled = true,
    this.initialValue,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (index) {
      final controller = TextEditingController();
      if (widget.initialValue != null && widget.initialValue!.length > index) {
        controller.text = widget.initialValue![index];
      }
      return controller;
    });
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(covariant OtpInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != null) {
      for (int i = 0; i < widget.length; i++) {
        if (widget.initialValue!.length > i) {
          _controllers[i].text = widget.initialValue![i];
        } else {
          _controllers[i].text = '';
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void clear() {
    for (var controller in _controllers) {
      controller.text = '';
    }
    _focusNodes[0].requestFocus();
  }

  void shake() {
    _shakeController.forward(from: 0);
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _handleChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        widget.onCompleted?.call(_currentOtp);
      }
    }
    widget.onChanged?.call(_currentOtp);
  }

  void _handleKeyPress(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].text = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double offset = (1 - _shakeController.value) * 10 * 
            ( (1 - _shakeController.value) > 0.5 ? 1 : -1);
        return Transform.translate(
          offset: Offset(_shakeController.isAnimating ? offset : 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              return SizedBox(
                width: 48,
                height: 56,
                child: RawKeyboardListener(
                  focusNode: FocusNode(), // Dummy focus node for key listener
                  onKey: (event) => _handleKeyPress(event, index),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: widget.enabled,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: widget.hasError 
                          ? AppColors.error 
                          : (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary),
                      fontWeight: FontWeight.w700,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.hasError 
                              ? AppColors.error 
                              : (Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.surfaceDark 
                                  : Colors.grey.shade200),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGold,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _handleChanged(value, index),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
