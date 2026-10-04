import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Картинка с бэкенда: подложка на время загрузки и заглушка, если
/// URL пустой или изображение не открылось.
class RemoteImage extends StatelessWidget {
  const RemoteImage(this.url, {this.fit = BoxFit.cover, super.key});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final source = url?.trim() ?? '';

    if (source.isEmpty) {
      return const _Placeholder();
    }

    return Image.network(
      source,
      fit: fit,
      errorBuilder: (context, error, stack) => const _Placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _Placeholder(showSpinner: true);
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.showSpinner = false});

  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.imagePlaceholder,
      child: Center(
        child: showSpinner
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.image_outlined,
                size: 28,
                color: AppColors.border,
              ),
      ),
    );
  }
}
