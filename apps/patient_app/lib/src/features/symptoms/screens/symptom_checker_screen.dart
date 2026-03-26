import 'package:ai_client/ai_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';

final _aiServiceProvider = Provider<AiService>((ref) {
  final client = SupabaseClientInitializer.client;
  return AiService(
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://jeantydukopukfvydixl.supabase.co'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplYW50eWR1a29wdWtmdnlkaXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1ODUxMzAsImV4cCI6MjA4OTE2MTEzMH0.TdZAU3iN5OPT9NmlhtISBme4GnKjd7lEG1vG4YH9byw'),
    accessToken: client.auth.currentSession?.accessToken,
  );
});

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() =>
      _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends ConsumerState<SymptomCheckerScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: 'Hi! I\'m your health assistant. Describe your symptoms and I\'ll provide personalized guidance based on your health history.\n\nRemember: This is not a diagnosis. Always consult a doctor for medical advice.',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
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

      final replyBuffer = StringBuffer();
      if (response.recommendations.isNotEmpty) {
        replyBuffer.writeln('**Recommendations:**');
        for (final rec in response.recommendations) {
          replyBuffer.writeln('• $rec');
        }
        replyBuffer.writeln();
      }
      if (response.whatToDo.isNotEmpty) {
        replyBuffer.writeln('**What to do:**');
        for (final item in response.whatToDo) {
          replyBuffer.writeln('• $item');
        }
        replyBuffer.writeln();
      }
      if (response.whatToAvoid.isNotEmpty) {
        replyBuffer.writeln('**What to avoid:**');
        for (final item in response.whatToAvoid) {
          replyBuffer.writeln('• $item');
        }
        replyBuffer.writeln();
      }
      if (response.whenToSeekHelp.isNotEmpty) {
        replyBuffer.writeln('**Seek help if:** ${response.whenToSeekHelp}\n');
      }
      replyBuffer.writeln('⚠️ This is AI-generated guidance, not a medical diagnosis. Please consult a qualified doctor.');

      setState(() {
        _messages.add(_ChatMessage(
          text: replyBuffer.toString(),
          isUser: false,
          triageLevel: response.triageLevel,
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Sorry, something went wrong. Please try again.',
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Checker')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: AppSpacing.screenPadding,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 48,
                        child: LinearProgressIndicator(),
                      ),
                    ),
                  );
                }
                final msg = _messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Describe your symptoms...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: _isLoading ? null : _sendMessage,
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

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.triageLevel,
  });
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  Color _triageColor(String level) {
    switch (level.toLowerCase()) {
      case 'emergency':
        return AppColors.error;
      case 'see_doctor':
      case 'see doctor':
        return AppColors.warning;
      case 'home_care':
      case 'home care':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  IconData _triageIcon(String level) {
    switch (level.toLowerCase()) {
      case 'emergency':
        return Icons.emergency;
      case 'see_doctor':
      case 'see doctor':
        return Icons.local_hospital;
      case 'home_care':
      case 'home care':
        return Icons.home;
      default:
        return Icons.info;
    }
  }

  String _triageLabel(String level) {
    switch (level.toLowerCase()) {
      case 'emergency':
        return 'Emergency';
      case 'see_doctor':
      case 'see doctor':
        return 'See a Doctor';
      case 'home_care':
      case 'home care':
        return 'Home Care';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.triageLevel != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _triageColor(message.triageLevel!).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _triageIcon(message.triageLevel!),
                      size: 16,
                      color: _triageColor(message.triageLevel!),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _triageLabel(message.triageLevel!),
                      style: AppTypography.caption.copyWith(
                        color: _triageColor(message.triageLevel!),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Text(
              message.text,
              style: AppTypography.bodyMedium.copyWith(
                color: message.isUser ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
