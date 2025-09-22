import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/profile_selector.dart';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.profileNotifier});

  final ValueNotifier<ProfileMode>? profileNotifier;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          '🐬 Hello! I\'m Della the FloatChat dolphin. Ask me about any ARGO float and I\'ll surface insights with maps, graphs, and context.',
      isUser: false,
    ),
  ];
  bool _isGenerating = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty || _isGenerating) return;

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _isGenerating = true;
      _controller.clear();
    });

    _scrollToBottom();

    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final profile = widget.profileNotifier?.value ?? ProfileMode.general;
      setState(() {
        _messages.add(ChatMessage(
          isUser: false,
          text: _mockResponse(profile, trimmed),
        ));
        _isGenerating = false;
      });
      _scrollToBottom();
    });
  }

  String _mockResponse(ProfileMode profile, String query) {
    final baseIntro = switch (profile) {
      ProfileMode.agency =>
          'For policy review: wave height anomalies near Bay of Bengal show +1.2m versus baseline.',
      ProfileMode.researcher =>
          'Research brief: Float 290313 analyzed. Thermocline dipped 35m post-monsoon burst.',
      ProfileMode.educator =>
          'Classroom snapshot: notice how warm surface water layers mix during summer monsoon.',
      ProfileMode.general =>
          'Ocean insight: surface temps are trending warmer around the Indian peninsula.',
    };

    return '$baseIntro\n\nBased on your prompt "$query", I\'ve staged depth vs temperature and salinity charts plus an oxygen anomaly timeline. Tap the Analysis tab to compare floats, overlay cyclonic events, or export NetCDF snapshots. 🐬';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length + (_isGenerating ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (_isGenerating && index == _messages.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        SizedBox(width: 12),
                        Text('Della is crafting insights...'),
                      ],
                    ),
                  ),
                );
              }

              final message = _messages[index];
              final alignment =
                  message.isUser ? Alignment.centerRight : Alignment.centerLeft;
              final bubbleColor = message.isUser
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceVariant.withOpacity(0.6);
              final textColor = message.isUser
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant;
              return Align(
                alignment: alignment,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: _buildInputBar(context),
        ),
      ],
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final theme = Theme.of(context);
    final selectedMode = widget.profileNotifier?.value ?? ProfileMode.general;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Upload files for analysis',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Upload Data',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Attach NetCDF, CSV, or imagery files to enrich the upcoming analysis. The preview and parsing will appear in chat. 🐬',
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ask Della to explore ARGO floats, trends, or anomalies...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ProfileSelectorChip(
              profileMode: selectedMode,
              onPressed: () {
                final notifier = widget.profileNotifier;
                if (notifier != null) {
                  showProfileSelector(context, notifier);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonal(
              onPressed: _isGenerating ? null : _sendMessage,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(18),
              ),
              child: const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
