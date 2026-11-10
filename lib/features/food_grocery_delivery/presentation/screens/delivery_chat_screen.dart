import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/delivery_chat_message.dart';
import '../providers/delivery_chat_provider.dart';

const _deliveryQuickMessages = <String>[
  'I am on my way',
  'I have arrived',
  'Please come outside',
  'I am a few minutes away',
  'Can you confirm your location?',
];

class DeliveryChatScreen extends ConsumerStatefulWidget {
  const DeliveryChatScreen({
    super.key,
    required this.deliveryId,
    required this.customerName,
  });

  final String deliveryId;
  final String customerName;

  @override
  ConsumerState<DeliveryChatScreen> createState() => _DeliveryChatScreenState();
}

class _DeliveryChatScreenState extends ConsumerState<DeliveryChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? quickMessage]) async {
    final message = quickMessage ?? _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    final sent = await ref
        .read(
          deliveryChatProvider(
            widget.deliveryId,
          ).notifier,
        )
        .sendMessage(message);

    if (!mounted || !sent) {
      return;
    }

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chatState = ref.watch(
      deliveryChatProvider(
        widget.deliveryId,
      ),
    );

    final backgroundColor =
        isDark ? AppColors.backgroundDarker : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: const Color(0xFF04213C),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF04213C).withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: const Color(0xFF04213C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Delivery chat',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF04213C).withValues(
                        alpha: 0.68,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (chatState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: AppColors.error.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  chatState.errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            Expanded(
              child: chatState.messages.isEmpty
                  ? _EmptyDeliveryChat(
                      isDark: isDark,
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        18,
                        16,
                        18,
                      ),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        return _DeliveryMessageBubble(
                          isDark: isDark,
                          message: chatState.messages[index],
                        );
                      },
                    ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _deliveryQuickMessages.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 7);
                },
                itemBuilder: (context, index) {
                  final message = _deliveryQuickMessages[index];

                  return ActionChip(
                    onPressed: chatState.isSending
                        ? null
                        : () {
                            _sendMessage(message);
                          },
                    label: Text(message),
                    backgroundColor:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    side: BorderSide(
                      color: AppColors.primaryGold.withValues(
                        alpha: 0.45,
                      ),
                    ),
                    labelStyle: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                12,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundSecondary
                    : AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.textMuted.withValues(
                            alpha: 0.25,
                          )
                        : AppColors.textMutedLight.withValues(
                            alpha: 0.30,
                          ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !chatState.isSending,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                      decoration: InputDecoration(
                        hintText: 'Message customer',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: chatState.isSending ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: const Color(0xFF04213C),
                        elevation: 0,
                        shape: const CircleBorder(),
                      ),
                      child: chatState.isSending
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF04213C),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDeliveryChat extends StatelessWidget {
  const _EmptyDeliveryChat({
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(
                  alpha: 0.13,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 32,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Message the customer',
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use chat only for updates related to this delivery.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryMessageBubble extends StatelessWidget {
  const _DeliveryMessageBubble({
    required this.isDark,
    required this.message,
  });

  final bool isDark;
  final DeliveryChatMessage message;

  String _formatTime(DateTime value) {
    final localValue = value.toLocal();
    final hour = localValue.hour.toString().padLeft(2, '0');
    final minute = localValue.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final sentByPartner = message.sentByPartner;

    return Align(
      alignment: sentByPartner ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(
          13,
          10,
          13,
          7,
        ),
        decoration: BoxDecoration(
          color: sentByPartner
              ? AppColors.primaryGold
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(
              sentByPartner ? 16 : 4,
            ),
            bottomRight: Radius.circular(
              sentByPartner ? 4 : 16,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: sentByPartner
                    ? const Color(0xFF04213C)
                    : (isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _formatTime(message.sentAt),
              style: AppTextStyles.labelSmall.copyWith(
                color: sentByPartner
                    ? const Color(0xFF04213C).withValues(
                        alpha: 0.65,
                      )
                    : (isDark ? AppColors.textMuted : AppColors.textMutedLight),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
