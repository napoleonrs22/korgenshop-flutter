import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Шаг квиза с фотографиями объекта.
///
/// Снимки нужны инженеру, чтобы прикинуть точки установки до выезда:
/// по кадру видно высоту, освещение и подходящие места крепления.
/// Шаг необязательный — заявку можно отправить и без него.
class PhotoStep extends StatefulWidget {
  const PhotoStep({
    required this.strings,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final AppStrings strings;
  final List<String> photos;
  final void Function(Iterable<String> paths) onAdd;
  final void Function(String path) onRemove;

  /// Столько файлов принимает бэкенд в одной заявке.
  static const limit = 10;

  @override
  State<PhotoStep> createState() => _PhotoStepState();
}

class _PhotoStepState extends State<PhotoStep> {
  final _picker = ImagePicker();

  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      // Снимок с камеры приходит по одному, из галереи — пачкой.
      final picked = source == ImageSource.camera
          ? [
              ?await _picker.pickImage(
                source: source,
                imageQuality: 70,
                maxWidth: 1920,
              ),
            ]
          : await _picker.pickMultiImage(imageQuality: 70, maxWidth: 1920);

      if (picked.isEmpty || !mounted) return;

      widget.onAdd(picked.map((file) => file.path));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(widget.strings.t('quiz.photo.error')),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final full = widget.photos.length >= PhotoStep.limit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.t('quiz.photo.question'),
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(strings.t('quiz.photo.hint'), style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PickButton(
                icon: Icons.photo_camera_outlined,
                label: strings.t('quiz.photo.camera'),
                onTap: full || _busy
                    ? null
                    : () => _pick(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PickButton(
                icon: Icons.photo_library_outlined,
                label: strings.t('quiz.photo.gallery'),
                onTap: full || _busy
                    ? null
                    : () => _pick(ImageSource.gallery),
              ),
            ),
          ],
        ),
        if (widget.photos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            strings.t(
              'quiz.photo.count',
              params: {
                'count': widget.photos.length,
                'limit': PhotoStep.limit,
              },
            ),
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final path in widget.photos)
                _Thumbnail(path: path, onRemove: () => widget.onRemove(path)),
            ],
          ),
        ],
      ],
    );
  }
}

class _PickButton extends StatelessWidget {
  const _PickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final color = disabled ? AppColors.textMuted : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.imagePlaceholder,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.control),
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
                // В тестах и на битом файле не роняем экран целиком.
                errorBuilder: (context, error, stack) => Container(
                  color: AppColors.imagePlaceholder,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
