import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Ссылка «отправить код ещё раз» с обратным отсчётом.
///
/// Таймер живёт только пока идёт отсчёт и сам себя гасит на нуле — иначе
/// периодический таймер не давал бы тестам дождаться покоя дерева.
class ResendControl extends StatefulWidget {
  const ResendControl({
    required this.initialSeconds,
    required this.label,
    required this.countdownText,
    required this.onResend,
    super.key,
  });

  /// Сколько ждать до первой возможной отправки. Регистрация и первый шаг
  /// восстановления письмо уже отправили, поэтому отсчёт стартует сразу.
  final int initialSeconds;
  final String label;

  /// Текст отсчёта: принимает оставшиеся секунды.
  final String Function(int secondsLeft) countdownText;

  /// Возвращает, сколько секунд ждать до следующей отправки.
  final Future<int> Function() onResend;

  @override
  State<ResendControl> createState() => _ResendControlState();
}

class _ResendControlState extends State<ResendControl> {
  Timer? _timer;
  late int _left = widget.initialSeconds;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _start(widget.initialSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(int seconds) {
    _timer?.cancel();
    setState(() => _left = seconds);

    if (seconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();

      setState(() => _left--);

      if (_left <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    setState(() => _busy = true);

    try {
      _start(await widget.onResend());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _left > 0;

    return Align(
      child: TextButton(
        onPressed: waiting || _busy ? null : _resend,
        child: Text(
          waiting ? widget.countdownText(_left) : widget.label,
          style: AppTextStyles.label.copyWith(
            color: waiting ? AppColors.textMuted : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
