import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/recipe_image_view.dart';
import '../../data/services/recipe_image_service.dart';

/// Interactive cover photo upload card for adding or editing a recipe.
/// Supports picking from Gallery, capturing from Camera, or entering an Image URL.
class RecipeImagePickerCard extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<String> onImageChanged;
  final RecipeImageService? imageService;

  const RecipeImagePickerCard({
    super.key,
    required this.imageUrl,
    required this.onImageChanged,
    this.imageService,
  });

  @override
  State<RecipeImagePickerCard> createState() => _RecipeImagePickerCardState();
}

class _RecipeImagePickerCardState extends State<RecipeImagePickerCard> {
  late final RecipeImageService _service = widget.imageService ?? RecipeImageService();
  bool _isUploading = false;

  Future<void> _pickFromSource(ImageSource source) async {
    if (_isUploading) return;
    setState(() => _isUploading = true);
    final uploadedUrl = await _service.pickAndUploadImage(source);
    if (!mounted) return;
    setState(() => _isUploading = false);
    if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
      widget.onImageChanged(uploadedUrl);
      CustomSnackbar.showSuccess(context, 'Recipe photo uploaded');
    }
  }

  Future<void> _showUrlDialog() async {
    final controller = TextEditingController(text: widget.imageUrl);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Recipe Image URL', style: getBoldStyle(context: ctx, fontSize: FontSize.s16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Image URL or Path',
            hintText: 'https://example.com/dish.jpg',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('Apply')),
        ],
      ),
    );
    controller.dispose();
    if (result != null && mounted) widget.onImageChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = widget.imageUrl.trim().isNotEmpty;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(
          color: hasImage ? AppColors.primary.withValues(alpha: 0.6) : borderColor,
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(11.r)),
              child: SizedBox(
                height: 110.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeImageView(imageSource: widget.imageUrl, fit: BoxFit.cover),
                    if (_isUploading)
                      Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
                    if (!_isUploading)
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: InkWell(
                          key: const Key('remove_recipe_image_button'),
                          onTap: () => widget.onImageChanged(''),
                          borderRadius: AppBorderRadius.circular,
                          child: Container(
                            padding: EdgeInsets.all(5.r),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: Icon(Icons.close_rounded, size: 16.r, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            InkWell(
              onTap: () => _pickFromSource(ImageSource.gallery),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11.r)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    Icon(Icons.add_a_photo_rounded, size: 20, color: AppColors.primary),
                    AppSpacing.gapW8,
                    Expanded(
                      child: Text(
                        'Upload Recipe Photo',
                        style: getBoldStyle(context: context, fontSize: FontSize.s13, color: isDark ? AppColors.primaryLight : AppColors.primary),
                      ),
                    ),
                    if (_isUploading)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Row(
              children: [
                Expanded(child: _buildActionChip(Icons.photo_library_outlined, 'Gallery', () => _pickFromSource(ImageSource.gallery))),
                AppSpacing.gapW8,
                Expanded(child: _buildActionChip(Icons.photo_camera_outlined, 'Camera', () => _pickFromSource(ImageSource.camera))),
                AppSpacing.gapW8,
                Expanded(child: _buildActionChip(Icons.link_rounded, 'Image URL', _showUrlDialog)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.r8,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainer.withValues(alpha: 0.45),
          borderRadius: AppBorderRadius.r8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            AppSpacing.gapW4,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getSemiBoldStyle(context: context, fontSize: FontSize.s11, color: isDark ? AppColors.primaryLight : AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
