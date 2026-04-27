import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/wardrobe_provider.dart';

class CameraScannerScreen extends ConsumerStatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  ConsumerState<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends ConsumerState<CameraScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;
  bool _isDetecting = false;

  Future<void> _captureFromCamera() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        context.pushNamed('scan-preview', extra: image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder a la cámara: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        context.pushNamed('scan-preview', extra: image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder a la galería: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _detectOutfitPhoto(ImageSource source) async {
    if (_isDetecting) return;
    setState(() => _isDetecting = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null || !mounted) return;

      final result = await ref
          .read(wardrobeRepositoryProvider)
          .detectFromPhoto(image.path);

      if (mounted) {
        context.pushNamed('garment-detection-confirm', extra: result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppException.extractMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Container(color: AppColors.primary),

            // Content
            Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Escanear prenda',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Scanner viewfinder area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Viewfinder frame
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Stack(
                            children: [
                              // Dark overlay with hole
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                ),
                              ),
                              // Corner markers
                              ..._buildCornerMarkers(),
                              // Center instruction
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.checkroom_outlined,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Text(
                                      'Posicioná la prenda\ndentro del marco',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'Asegurate de que la prenda esté bien iluminada y centrada',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxxl,
                    AppSpacing.xl,
                    AppSpacing.xxxl,
                    AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      _buildControlButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Galería',
                        onTap: _pickFromGallery,
                        size: 52,
                        iconSize: 22,
                      ),

                      // Capture button
                      GestureDetector(
                        onTap: _captureFromCamera,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isPickingImage
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 32,
                                ),
                        ),
                      ),

                      // Placeholder for symmetry
                      _buildControlButton(
                        icon: Icons.flash_off_outlined,
                        label: 'Flash',
                        onTap: () {},
                        size: 52,
                        iconSize: 22,
                      ),
                    ],
                  ),
                ),

                // Detect outfit option
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: GestureDetector(
                    key: const Key('detect_outfit_photo_btn'),
                    onTap: _isDetecting
                        ? null
                        : () => _detectOutfitPhoto(ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: _isDetecting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_camera_outlined,
                                    color: Colors.white, size: 16),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Foto de mi outfit completo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double size,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const markerLength = 24.0;
    const markerThickness = 3.0;
    const markerColor = AppColors.accent;
    const radius = Radius.circular(4);

    Widget corner({
      required Alignment alignment,
      required BorderRadius borderRadius,
    }) {
      return Align(
        alignment: alignment,
        child: SizedBox(
          width: markerLength,
          height: markerLength,
          child: CustomPaint(
            painter: _CornerPainter(
              borderRadius: borderRadius,
              color: markerColor,
              thickness: markerThickness,
            ),
          ),
        ),
      );
    }

    return [
      corner(
        alignment: Alignment.topLeft,
        borderRadius: const BorderRadius.only(topLeft: radius),
      ),
      corner(
        alignment: Alignment.topRight,
        borderRadius: const BorderRadius.only(topRight: radius),
      ),
      corner(
        alignment: Alignment.bottomLeft,
        borderRadius: const BorderRadius.only(bottomLeft: radius),
      ),
      corner(
        alignment: Alignment.bottomRight,
        borderRadius: const BorderRadius.only(bottomRight: radius),
      ),
    ];
  }
}

class _CornerPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color color;
  final double thickness;

  const _CornerPainter({
    required this.borderRadius,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (borderRadius.topLeft != Radius.zero) {
      path.moveTo(0, h);
      path.lineTo(0, 4);
      path.arcToPoint(const Offset(4, 0), radius: const Radius.circular(4));
      path.lineTo(w, 0);
    } else if (borderRadius.topRight != Radius.zero) {
      path.moveTo(0, 0);
      path.lineTo(w - 4, 0);
      path.arcToPoint(Offset(w, 4), radius: const Radius.circular(4));
      path.lineTo(w, h);
    } else if (borderRadius.bottomLeft != Radius.zero) {
      path.moveTo(w, h);
      path.lineTo(4, h);
      path.arcToPoint(Offset(0, h - 4), radius: const Radius.circular(4));
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, h);
      path.lineTo(w - 4, h);
      path.arcToPoint(Offset(w, h - 4), radius: const Radius.circular(4));
      path.lineTo(w, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
