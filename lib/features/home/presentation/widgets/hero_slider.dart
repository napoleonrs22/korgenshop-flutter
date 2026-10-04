import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/hero_banner.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/remote_image.dart';

/// Hero-баннер главной: фото под синей заливкой, градиент слева,
/// бейдж, заголовок, кнопка и точки-индикаторы.
class HeroSlider extends StatefulWidget {
  const HeroSlider({required this.banners, required this.onCtaTap, super.key});

  final List<HeroBanner> banners;
  final void Function(HeroBanner banner) onCtaTap;

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  late final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 216,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => _HeroSlide(
                banner: widget.banners[i],
                onCtaTap: () => widget.onCtaTap(widget.banners[i]),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.banners.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                      width: i == _index ? 32 : 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.banner, required this.onCtaTap});

  final HeroBanner banner;
  final VoidCallback onCtaTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.primary),
        Opacity(opacity: 0.4, child: RemoteImage(banner.image)),
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0x00004688)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FractionallySizedBox(
            widthFactor: 0.80,
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    banner.label,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    banner.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                _HeroButton(label: banner.ctaLabel, onTap: onCtaTap),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              const AppIcon.square(
                'arrow_right_long',
                size: 10.667,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
