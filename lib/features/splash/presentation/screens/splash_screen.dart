import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Заставка при запуске: знак проявляется, следом подпись.
///
/// Фон совпадает с цветом нативного экрана запуска Android, поэтому переход
/// от системной заставки к приложению не мигает белым.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Лазурный со знака на сайте — тот же, что залит в иконку приложения.
  static const background = Color(0xFF0058F6);

  static const _total = Duration(milliseconds: 1260);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashScreen._total,
  );

  // Знак: масштаб от 0.88 и проявление за первые 520 мс.
  late final Animation<double> _markFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, .41, curve: Curves.easeOut),
  );

  late final Animation<double> _markScale = Tween(begin: .88, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .41, curve: Curves.easeOutCubic),
    ),
  );

  // Подпись подключается позже и подъезжает снизу.
  late final Animation<double> _wordFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(.21, .54, curve: Curves.easeOut),
  );

  late final Animation<double> _wordShift = Tween(begin: 12.0, end: 0.0)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(.21, .54, curve: Curves.easeOutCubic),
        ),
      );

  bool _left = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onDone);
    _controller.forward();
  }

  void _onDone(AnimationStatus status) {
    if (status == AnimationStatus.completed) _leave();
  }

  /// Уходим один раз: статус может прийти повторно при перестроении.
  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onDone);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Если в системе выключены анимации, показывать нечего — сразу дальше.
    if (MediaQuery.disableAnimationsOf(context) && !_left) {
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _leave());
    }

    return Scaffold(
      backgroundColor: SplashScreen.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: _markFade.value,
                child: Transform.scale(
                  scale: _markScale.value,
                  child: SvgPicture.asset(
                    'assets/icons/logo_bag.svg',
                    width: 104,
                    height: 104,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Opacity(
                opacity: _wordFade.value,
                child: Transform.translate(
                  offset: Offset(0, _wordShift.value),
                  child: const _Wordmark(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Надпись под знаком — тем же шрифтом, что и логотип в шапке приложения.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final logo = AppTextStyles.logo;

    return Column(
      children: [
        Text(
          'KORGEN',
          style: logo.copyWith(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 2.4,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'SHOP',
          style: logo.copyWith(
            color: const Color(0xB3FFFFFF),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            height: 1,
          ),
        ),
      ],
    );
  }
}
