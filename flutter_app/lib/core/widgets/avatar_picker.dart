import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/design_tokens.dart';
import '../theme/app_colors.dart';

/// TekTech AvatarPicker - WhatsApp-Style Profile Photo Picker
///
/// Features:
/// - Camera or gallery selection
/// - Circular avatar preview
/// - Remove option
/// - WhatsApp-inspired bottom sheet
class AvatarPicker extends StatefulWidget {
  final String? initialImageUrl;
  final void Function(File?)? onImageSelected;
  final double size;

  const AvatarPicker({
    super.key,
    this.initialImageUrl,
    this.onImageSelected,
    this.size = 120,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = _imageFile != null || widget.initialImageUrl != null;

    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: Stack(
        children: [
          // Avatar circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: hasImage
                  ? _buildImagePreview()
                  : Icon(
                      Icons.person,
                      size: widget.size * 0.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),

          // Camera badge (bottom right)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 3,
                ),
              ),
              child: Icon(
                hasImage ? Icons.edit : Icons.add_a_photo,
                size: 20,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    } else if (widget.initialImageUrl != null) {
      return Image.network(
        widget.initialImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: widget.size * 0.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _showImageSourceOptions() async {
    final hasImage = _imageFile != null || widget.initialImageUrl != null;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheet,
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Profil Fotoğrafı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: AppSpacing.md),

              // Camera option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusSM,
                ),
              ),

              // Gallery option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.info),
                ),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusSM,
                ),
              ),

              // Remove option (if image exists)
              if (hasImage)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete, color: AppColors.error),
                  ),
                  title: const Text('Fotoğrafı Kaldır'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSM,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        widget.onImageSelected?.call(_imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
    widget.onImageSelected?.call(null);
  }
}
