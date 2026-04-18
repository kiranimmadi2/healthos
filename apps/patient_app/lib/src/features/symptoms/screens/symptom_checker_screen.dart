import 'package:ai_client/ai_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';

final _aiServiceProvider = Provider<AiService>((ref) {
  final client = SupabaseClientInitializer.client;
  return AiService(
    supabaseUrl: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://gmozpsolmfwrihktdeqh.supabase.co',
    ),
    supabaseAnonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdtb3pwc29sbWZ3cmloa3RkZXFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3NjQxMTEsImV4cCI6MjA5MDM0MDExMX0.itV_0F4iuSvepl5cw4SAj52gFy_Vb2lu8QTEu-mhDHs',
    ),
    accessToken: client.auth.currentSession?.accessToken,
  );
});

const _suggestedPrompts = [
  'Headache and mild fever since yesterday',
  'Sore throat with cough',
  'Persistent fatigue for 3 days',
  'Stomach pain after eating',
];

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() =>
      _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState
    extends ConsumerState<SymptomCheckerScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocus = FocusNode();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text:
            'Hi! I\'m your AI health assistant. Tell me what you\'re feeling and I\'ll give you guidance based on your health history.\n\nThis is not a diagnosis — always consult a doctor for medical advice.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? seed}) async {
    final text = (seed ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final patient = await ref.read(currentPatientProvider.future);
      if (patient == null) throw Exception('Profile not found');

      final aiService = ref.read(_aiServiceProvider);
      final response = await aiService.checkSymptoms(
        SymptomRequest(patientId: patient.id, symptoms: text),
      );

      setState(() {
        _messages.add(
          _ChatMessage(
            text: _formatResponse(response),
            isUser: false,
            triageLevel: response.triageLevel,
            recommendations: response.recommendations,
            whatToDo: response.whatToDo,
            whatToAvoid: response.whatToAvoid,
            whenToSeekHelp: response.whenToSeekHelp.isEmpty
                ? null
                : response.whenToSeekHelp,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'Sorry, I couldn\'t process that just now. Please try again in a moment.',
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  String _formatResponse(AiSymptomResponse r) {
    final b = StringBuffer();
    if (r.recommendations.isNotEmpty) {
      b.writeln('Here\'s what I\'m seeing based on your description:');
    }
    return b.toString().trim();
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
    final theme = Theme.of(context);
    final showSuggestions = _messages.length == 1 && !_isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(HosIcons.ai,
                  size: 16, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Symptom checker'),
          ],
        ),
        actions: [
          HosIconButton(
            icon: HosIcons.refresh,
            tooltip: 'Restart',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(
                  text:
                      'Hi! I\'m your AI health assistant. Tell me what you\'re feeling.',
                  isUser: false,
                ));
              });
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: AppSpacing.screenPadding,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const _TypingBubble();
                }
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (showSuggestions)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedPrompts.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (_, i) {
                    final p = _suggestedPrompts[i];
                    return ActionChip(
                      label: Text(p),
                      onPressed: () => _sendMessage(seed: p),
                    );
                  },
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _inputFocus,
                      decoration: InputDecoration(
                        hintText: 'Describe your symptoms…',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.borderRadius),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.borderRadius),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(HosIcons.send,
                          color: AppColors.white, size: 20),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
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

class _ChatMessage {
  final String text;
  final bool isUser;
  final String? triageLevel;
  final List<String>? recommendations;
  final List<String>? whatToDo;
  final List<String>? whatToAvoid;
  final String? whenToSeekHelp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.triageLevel,
    this.recommendations,
    this.whatToDo,
    this.whatToAvoid,
    this.whenToSeekHelp,
  });
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  Color _triageColor(String level) {
    switch (level.toLowerCase()) {
      case 'emergency':
        return AppColors.triageEmergency;
      case 'see_doctor':
      case 'see doctor':
        return AppColors.triageSeeDoctor;
      case 'home_care':
      case 'home care':
        return AppColors.triageHomeCare;
      default:
        return AppColors.info;
    }
  }

  IconData _triageIcon(String level) {
    switch (level.toLowerCase()) {
      case 'emergency':
        return HosIcons.warning;
      case 'see_doctor':
      case 'see doctor':
        return HosIcons.symptoms;
      case 'home_care':
      case 'home care':
        return HosIcons.home;
      default:
        return HosIcons.info;
    }
  }

  String _triageLabel(String level) {
    switch (level.toLowerCase()) {
      case 'emergency':
        return 'Emergency — seek care immediately';
      case 'see_doctor':
      case 'see doctor':
        return 'See a doctor soon';
      case 'home_care':
      case 'home care':
        return 'Home care';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.borderRadius),
              topRight: Radius.circular(AppSpacing.borderRadius),
              bottomLeft: Radius.circular(AppSpacing.borderRadius),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.text,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          ),
        ),
      );
    }

    // Assistant bubble — may include rich triage card
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(AppSpacing.borderRadius),
                  bottomLeft: Radius.circular(AppSpacing.borderRadius),
                  bottomRight: Radius.circular(AppSpacing.borderRadius),
                ),
              ),
              child: Text(
                message.text.isEmpty ? 'Here\'s what I found:' : message.text,
                style: AppTypography.bodyMedium,
              ),
            ),
            if (message.triageLevel != null) _triageCard(context),
            if (message.recommendations != null &&
                message.recommendations!.isNotEmpty)
              _section(
                context,
                icon: HosIcons.info,
                title: 'Recommendations',
                items: message.recommendations!,
              ),
            if (message.whatToDo != null && message.whatToDo!.isNotEmpty)
              _section(
                context,
                icon: HosIcons.success,
                title: 'What to do',
                items: message.whatToDo!,
                accent: AppColors.success,
              ),
            if (message.whatToAvoid != null &&
                message.whatToAvoid!.isNotEmpty)
              _section(
                context,
                icon: HosIcons.blocked,
                title: 'What to avoid',
                items: message.whatToAvoid!,
                accent: AppColors.error,
              ),
            if (message.whenToSeekHelp != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: HosCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(HosIcons.warning,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Seek help if: ',
                                style: AppTypography.label,
                              ),
                              TextSpan(text: message.whenToSeekHelp!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (message.triageLevel != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'AI-generated guidance. Not a medical diagnosis.',
                  style: AppTypography.caption,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _triageCard(BuildContext context) {
    final color = _triageColor(message.triageLevel!);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_triageIcon(message.triageLevel!),
                  color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                _triageLabel(message.triageLevel!),
                style: AppTypography.label.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> items,
    Color? accent,
  }) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: HosCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTypography.label.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ...items.map(
              (it) => Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, right: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(it, style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              AnimatedBuilder(
                animation: _controller,
                builder: (_, _) {
                  final phase = (_controller.value + i * 0.2) % 1.0;
                  final opacity =
                      (0.3 + 0.7 * (1 - (phase - 0.5).abs() * 2)).clamp(0.3, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
