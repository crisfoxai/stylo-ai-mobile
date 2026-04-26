import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../subscription/domain/entities/subscription.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasChat = ref.watch(hasChatProvider);

    if (!hasChat) {
      return const PaywallScreen(feature: PaywallFeature.chat);
    }

    final chatState = ref.watch(chatProvider);
    final plan = ref.watch(subscriptionPlanProvider);

    // Scroll when messages change
    ref.listen(chatProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0) ||
          next.isSending != (prev?.isSending ?? false)) {
        _scrollToBottom();
      }
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () => ref.read(chatProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              'Mi Estilista',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _PlanChip(plan: plan),
          ],
        ),
        centerTitle: false,
        bottom: plan == SubscriptionPlan.stylist &&
                chatState.messagesLimitThisMonth != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    bottom: AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${chatState.messagesUsedThisMonth ?? 0}/'
                      '${chatState.messagesLimitThisMonth} mensajes este mes',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty && !chatState.isSending
                ? const _EmptyState()
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: chatState.messages.length +
                        (chatState.isSending ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length) {
                        return const LoadingBubble();
                      }
                      return MessageBubble(
                          message: chatState.messages[index]);
                    },
                  ),
          ),
          ChatInput(
            enabled: !chatState.isSending,
            onSubmit: (text) =>
                ref.read(chatProvider.notifier).sendMessage(text),
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  final SubscriptionPlan plan;

  const _PlanChip({required this.plan});

  String get _label => switch (plan) {
        SubscriptionPlan.stylist => 'Stylist',
        SubscriptionPlan.pro => 'Pro',
        SubscriptionPlan.proUnlimited => 'Pro ∞',
        SubscriptionPlan.free => 'Free',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSubtle,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '¡Hola! Soy tu estilista personal.',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Preguntame qué ponerte para cualquier ocasión, o pedime que combine prendas de tu guardarropa.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
