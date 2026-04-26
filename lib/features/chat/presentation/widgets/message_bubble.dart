import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            const _StylistAvatar(),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: _isUser ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(_isUser ? AppRadius.lg : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : AppRadius.lg),
                ),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: _isUser ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (_isUser) const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _StylistAvatar extends StatelessWidget {
  const _StylistAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.accentSubtle,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('✨', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class LoadingBubble extends StatefulWidget {
  const LoadingBubble({super.key});

  @override
  State<LoadingBubble> createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<LoadingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _StylistAvatar(),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Dot(delay: 0, animation: _animation),
                  const SizedBox(width: 4),
                  _Dot(delay: 0.3, animation: _animation),
                  const SizedBox(width: 4),
                  _Dot(delay: 0.6, animation: _animation),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double delay;
  final Animation<double> animation;

  const _Dot({required this.delay, required this.animation});

  @override
  Widget build(BuildContext context) {
    final value = (animation.value - delay).clamp(0.0, 1.0);
    final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(0.3, 1.0);
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
