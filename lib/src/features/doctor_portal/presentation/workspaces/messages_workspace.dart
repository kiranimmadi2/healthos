import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../chat/application/chat_providers.dart';
import '../../../chat/domain/chat_message.dart';
import '../../../chat/domain/chat_thread.dart';
import '../widgets/doctor_workspace_widgets.dart';

class MessagesWorkspace extends ConsumerStatefulWidget {
  const MessagesWorkspace({super.key});

  @override
  ConsumerState<MessagesWorkspace> createState() => _MessagesWorkspaceState();
}

class _MessagesWorkspaceState extends ConsumerState<MessagesWorkspace> {
  String? _selectedThreadId;
  String _query = '';
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(String threadId) async {
    final text = _controller.text.trim();
    final uid = ref.read(authStateProvider).value?.uid;
    if (text.isEmpty || uid == null || _sending) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(threadId: threadId, senderId: uid, text: text);
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not send message: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final threadsAsync = ref.watch(chatThreadsProvider);
    final currentUid = ref.watch(authStateProvider).value?.uid;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 880) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedThreadId == null) ...[
                  const WorkspaceHeading(
                    title: 'Secure messages',
                    description: 'Chat with patients in one place.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Expanded(
                  child: threadsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => _MessageEmptyState(
                      fill: true,
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load messages',
                      description: '$e',
                    ),
                    data: (threads) => _buildMobileContent(threads, currentUid),
                  ),
                ),
              ],
            ),
          );
        }

        return HealthPage(
          maxWidth: 1380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkspaceHeading(
                title: 'Secure messages',
                description:
                    'Keep patient and care-team conversations in one place.',
              ),
              const SizedBox(height: AppSpacing.xl),
              threadsAsync.when(
                loading: () => const SizedBox(
                  height: 500,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => _MessageEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load messages',
                  description: '$e',
                ),
                data: (threads) => _buildWideContent(threads, currentUid),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileContent(List<ChatThread> threads, String? currentUid) {
    if (threads.isEmpty) {
      return const _MessageEmptyState(
        fill: true,
        icon: Icons.forum_outlined,
        title: 'No conversations yet',
        description:
            'Patient messages will appear here when a conversation starts.',
      );
    }

    ChatThread? selected;
    for (final thread in threads) {
      if (thread.id == _selectedThreadId) {
        selected = thread;
        break;
      }
    }

    if (selected != null) {
      return _LiveMessageThread(
        thread: selected,
        currentUid: currentUid,
        controller: _controller,
        sending: _sending,
        onBack: () => setState(() => _selectedThreadId = null),
        onSend: () => _send(selected!.id),
      );
    }

    return _ConversationList(
      threads: _filteredThreads(threads, currentUid),
      currentUid: currentUid,
      selectedThreadId: null,
      onSearch: (value) => setState(() => _query = value),
      onSelected: (id) => setState(() => _selectedThreadId = id),
    );
  }

  Widget _buildWideContent(List<ChatThread> threads, String? currentUid) {
    if (threads.isEmpty) {
      return const _MessageEmptyState(
        icon: Icons.forum_outlined,
        title: 'No conversations yet',
        description:
            'Patient messages will appear here as soon as they start a conversation.',
      );
    }

    final selectedId = threads.any((thread) => thread.id == _selectedThreadId)
        ? _selectedThreadId!
        : threads.first.id;
    final selected = threads.firstWhere((thread) => thread.id == selectedId);

    return SizedBox(
      height: 690,
      child: Row(
        children: [
          SizedBox(
            width: 340,
            child: _ConversationList(
              threads: _filteredThreads(threads, currentUid),
              currentUid: currentUid,
              selectedThreadId: selectedId,
              onSearch: (value) => setState(() => _query = value),
              onSelected: (id) => setState(() => _selectedThreadId = id),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _LiveMessageThread(
              thread: selected,
              currentUid: currentUid,
              controller: _controller,
              sending: _sending,
              onSend: () => _send(selected.id),
            ),
          ),
        ],
      ),
    );
  }

  List<ChatThread> _filteredThreads(
    List<ChatThread> threads,
    String? currentUid,
  ) {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return threads;
    return threads.where((thread) {
      return _otherPartyName(
        thread,
        currentUid,
      ).toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}

String _otherPartyName(ChatThread thread, String? currentUid) {
  return currentUid == thread.patientId
      ? thread.doctorName
      : thread.patientName;
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.threads,
    required this.currentUid,
    required this.selectedThreadId,
    required this.onSearch,
    required this.onSelected,
  });

  final List<ChatThread> threads;
  final String? currentUid;
  final String? selectedThreadId;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Search conversations',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: threads.isEmpty
                ? const Center(child: Text('No matching conversations'))
                : ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: threads.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      final name = _otherPartyName(thread, currentUid);
                      final selected = selectedThreadId == thread.id;
                      return InkWell(
                        onTap: () => onSelected(thread.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.all(16),
                          color: selected ? AppColors.primarySoft : null,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.secondarySoft,
                                child: Text(
                                  name.isEmpty ? '?' : name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (thread.lastMessageAt != null)
                                          Text(
                                            DateFormat(
                                              'HH:mm',
                                            ).format(thread.lastMessageAt!),
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      thread.lastMessage.isEmpty
                                          ? 'Conversation started'
                                          : thread.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LiveMessageThread extends ConsumerStatefulWidget {
  const _LiveMessageThread({
    required this.thread,
    required this.currentUid,
    required this.controller,
    required this.sending,
    required this.onSend,
    this.onBack,
  });

  final ChatThread thread;
  final String? currentUid;
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback? onBack;

  @override
  ConsumerState<_LiveMessageThread> createState() => _LiveMessageThreadState();
}

class _LiveMessageThreadState extends ConsumerState<_LiveMessageThread> {
  final _scrollController = ScrollController();
  int _messageCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _LiveMessageThread oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
    if (oldWidget.thread.id != widget.thread.id) {
      _messageCount = 0;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _scrollToLatest(int messageCount) {
    if (messageCount == _messageCount) return;
    _messageCount = messageCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.thread.id));
    final name = _otherPartyName(widget.thread, widget.currentUid);
    final canSend = widget.controller.text.trim().isNotEmpty && !widget.sending;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(
                    tooltip: 'Back to conversations',
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                CircleAvatar(
                  backgroundColor: AppColors.secondarySoft,
                  child: Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 4),
                          Text('Secure patient conversation'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Could not load: $e')),
              data: (messages) {
                _scrollToLatest(messages.length);
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation.'),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      isMine: message.senderId == widget.currentUid,
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Write a message',
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: canSend ? widget.onSend : null,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.border,
                    ),
                    icon: widget.sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.74;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth.clamp(220.0, 440.0).toDouble(),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 8),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMine ? Colors.white : AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ),
            if (message.sentAt != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.sentAt!),
                style: TextStyle(
                  color: isMine ? Colors.white70 : AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageEmptyState extends StatelessWidget {
  const _MessageEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.fill = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
    if (fill) return SizedBox.expand(child: card);
    return SizedBox(height: 500, child: card);
  }
}
