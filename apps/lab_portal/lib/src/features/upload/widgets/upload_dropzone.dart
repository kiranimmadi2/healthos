import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class UploadDropzone extends StatefulWidget {
  const UploadDropzone({
    super.key,
    required this.onTap,
    this.isUploading = false,
    this.fileName,
  });

  final VoidCallback onTap;
  final bool isUploading;
  final String? fileName;

  @override
  State<UploadDropzone> createState() => _UploadDropzoneState();
}

class _UploadDropzoneState extends State<UploadDropzone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isUploading ? null : widget.onTap,
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (_) {
          setState(() => _isDragOver = true);
          return true;
        },
        onLeave: (_) {
          setState(() => _isDragOver = false);
        },
        onAcceptWithDetails: (_) {
          setState(() => _isDragOver = false);
          widget.onTap();
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: _isDragOver
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDragOver
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                width: _isDragOver ? 2 : 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isUploading) ...[
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Uploading...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ] else if (widget.fileName != null) ...[
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.fileName!,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap to change file',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: _isDragOver
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Drag & drop your report here',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'or click to browse files',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Supports PDF, JPG, PNG (max 10 MB)',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
