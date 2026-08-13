import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/domain/app_failure.dart';
import '../../../shared/presentation/widgets/hos_states.dart';
import '../../auth/application/user_providers.dart';
import '../application/ai_triage_providers.dart';

class AITriageScreen extends ConsumerStatefulWidget {
  const AITriageScreen({super.key});

  @override
  ConsumerState<AITriageScreen> createState() => _AITriageScreenState();
}

class _AITriageScreenState extends ConsumerState<AITriageScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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

  Future<void> _sendMessage([String? presetText]) async {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty || _isLoading) return;

    if (presetText == null) {
      _controller.clear();
    }

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final profile = ref.read(currentUserProfileProvider).value;
      final triage = await ref
          .read(aiServiceProvider)
          .getTriage(text, patientProfile: profile);

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: triage,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      // Record the failure as a failure. Never substitute invented guidance.
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: describeFailure(e),
            isUser: false,
            isError: true,
            retryPrompt: text,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation?'),
        content: const Text('This will clear all current messages in this triage session.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _messages.clear());
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) =>
                            _buildChatBubble(_messages[index], isDark),
                      ),
              ),
              if (_isLoading) _buildLoadingIndicator(isDark),
              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final suggestions = [
      'Persistent headache & dizziness',
      'Mild fever and sore throat for 2 days',
      'Lower back tightness after exercise',
      'Healthy diet advice for weight management',
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How can I help with your health today?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Text(
                'Describe any non-emergency symptoms or ask health questions for personalized guidance & triage recommendation.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final suggestion in suggestions)
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _sendMessage(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.25)
                                : const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 15,
                            color: Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            suggestion,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildChatBubble(_ChatMessage message, bool isDark) {
    if (message.isError) return _buildErrorBubble(message);

    final isUser = message.isUser;
    final rawText = message.text;

    // Detect Triage Badge details for AI response
    _TriageCategoryInfo? triageInfo;
    String displayText = rawText;

    if (!isUser) {
      if (rawText.startsWith('EMERGENCY:')) {
        triageInfo = _TriageCategoryInfo(
          title: 'EMERGENCY - URGENT ACTION',
          icon: Icons.error_rounded,
          color: const Color(0xFFEF4444),
          bgColor: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFCA5A5),
        );
        displayText = rawText.substring('EMERGENCY:'.length).trimLeft();
      } else if (rawText.startsWith('SEE DOCTOR:')) {
        triageInfo = _TriageCategoryInfo(
          title: 'RECOMMENDED: CONSULT A DOCTOR',
          icon: Icons.medical_services_rounded,
          color: const Color(0xFFF59E0B),
          bgColor: isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
        );
        displayText = rawText.substring('SEE DOCTOR:'.length).trimLeft();
      } else if (rawText.startsWith('HOME CARE:')) {
        triageInfo = _TriageCategoryInfo(
          title: 'HOME CARE & REMEDIES',
          icon: Icons.home_rounded,
          color: const Color(0xFF10B981),
          bgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
          borderColor: const Color(0xFFA7F3D0),
        );
        displayText = rawText.substring('HOME CARE:'.length).trimLeft();
      } else if (rawText.startsWith('HEALTH ADVICE:')) {
        triageInfo = _TriageCategoryInfo(
          title: 'PERSONALIZED HEALTH ADVICE',
          icon: Icons.lightbulb_rounded,
          color: const Color(0xFF3B82F6),
          bgColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
        );
        displayText = rawText.substring('HEALTH ADVICE:'.length).trimLeft();
      } else {
        triageInfo = _TriageCategoryInfo(
          title: 'PERSONALIZED CLINICAL GUIDANCE',
          icon: Icons.health_and_safety_rounded,
          color: const Color(0xFF3B82F6),
          bgColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF2563EB)
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 20),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFF2563EB).withValues(alpha: 0.25)
                        : (isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : const Color(0xFF0F172A).withValues(alpha: 0.05)),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (triageInfo != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: triageInfo.bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: triageInfo.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            triageInfo.icon,
                            size: 16,
                            color: triageInfo.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            triageInfo.title,
                            style: TextStyle(
                              color: triageInfo.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Text(
                    displayText,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B)),
                      fontSize: 15,
                      fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Color(0xFF3B82F6),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: const HosTypingIndicator(label: 'Analyzing your message'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBubble(_ChatMessage message) {
    final prompt = message.retryPrompt;
    return _ErrorBubble(
      message: message.text,
      onRetry: prompt == null
          ? null
          : () {
              setState(() => _messages.remove(message));
              _sendMessage(prompt);
            },
    );
  }

  Widget _buildInputArea(bool isDark) {
    final hasText = _controller.text.trim().isNotEmpty;

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: hasText
                  ? const Color(0xFF2563EB)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              width: hasText ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: hasText
                    ? const Color(0xFF2563EB).withValues(alpha: 0.25)
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : const Color(0xFF0F172A).withValues(alpha: 0.06)),
                blurRadius: hasText ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: hasText
                    ? const Color(0xFF2563EB)
                    : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe symptoms or ask health questions...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _isLoading ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasText && !_isLoading
                            ? [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                            : (isDark
                                ? [const Color(0xFF334155), const Color(0xFF334155)]
                                : [const Color(0xFFE2E8F0), const Color(0xFFE2E8F0)]),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: hasText && !_isLoading
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: hasText && !_isLoading
                          ? Colors.white
                          : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  /// True when this entry records a failure to reach the model rather than a
  /// model response. Kept distinct so a failure can never be mistaken for
  /// medical guidance — the previous version appended a friendly-sounding
  /// sentence that looked exactly like a real answer.
  final bool isError;

  /// The user text that produced this failure, so it can be retried.
  final String? retryPrompt;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.retryPrompt,
  });
}

/// Distinct treatment for "we could not reach the model".
///
/// Deliberately does not look like an assistant reply: it is visibly an error,
/// states that the question was not analysed, and offers a retry.
class _ErrorBubble extends StatelessWidget {
  const _ErrorBubble({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 40),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hos.dangerBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: hos.dangerFg.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_off_rounded, size: 18, color: hos.dangerFg),
                const SizedBox(width: 8),
                Text(
                  'Care Assistant unavailable',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: hos.dangerFg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$message\n\nYour question was not analysed — nothing here is '
              'medical advice. Please try again, or book a doctor.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hos.textSecondary,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TriageCategoryInfo {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  _TriageCategoryInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });
}
