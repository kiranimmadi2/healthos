import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai_service.dart';

class AITriageScreen extends ConsumerStatefulWidget {
  const AITriageScreen({super.key});

  @override
  ConsumerState<AITriageScreen> createState() => _AITriageScreenState();
}

class _AITriageScreenState extends ConsumerState<AITriageScreen> {
  final _controller = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _analyze() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _result = '';
    });
    
    try {
      final triage = await ref.read(aiServiceProvider).getTriage(_controller.text);
      setState(() => _result = triage);
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Describe your symptoms',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'e.g., I have a sharp pain in my chest and difficulty breathing...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _analyze,
            icon: const Icon(Icons.bolt),
            label: const Text('Analyze with AI'),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_result.isNotEmpty)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(_result),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
