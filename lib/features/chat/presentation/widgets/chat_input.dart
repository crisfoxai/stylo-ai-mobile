import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ChatInput extends StatefulWidget {
  final bool enabled;
  final void Function(String) onSubmit;

  const ChatInput({
    super.key,
    required this.enabled,
    required this.onSubmit,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSubmit(text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: widget.enabled
                    ? 'Preguntale a tu estilista...'
                    : 'Enviando...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
              ),
              onChanged: (v) => setState(() => _hasText = v.trim().isNotEmpty),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            onPressed: (_hasText && widget.enabled) ? _submit : null,
            icon: Icon(
              PhosphorIconsFill.paperPlaneRight,
              color: (_hasText && widget.enabled)
                  ? AppColors.accent
                  : AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}
