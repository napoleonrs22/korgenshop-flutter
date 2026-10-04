import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/remote_image.dart';

/// Галерея на всю ширину с точками-индикаторами и кнопкой поверх фото.
class ProductGallery extends StatefulWidget {
  const ProductGallery({required this.images, super.key});

  final List<String> images;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  late final PageController _controller = PageController();
  int _index = 0;
  bool _favorite = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 389,
      decoration: const BoxDecoration(
        color: AppColors.imagePlaceholder,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => RemoteImage(widget.images[i]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.images.length; i++)
                  Container(
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Material(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              elevation: 1,
              shadowColor: const Color(0x0D000000),
              child: InkWell(
                onTap: () => setState(() => _favorite = !_favorite),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: _favorite
                        ? const Icon(
                            Icons.favorite,
                            size: 18,
                            color: AppColors.primary,
                          )
                        : const AppIcon.square(
                            'zoom',
                            size: 18,
                            color: AppColors.primary,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
