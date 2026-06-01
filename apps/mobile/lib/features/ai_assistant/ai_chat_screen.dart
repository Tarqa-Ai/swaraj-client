import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/services/cache_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  String get _userInitials {
    final name = SwarajCacheService.getUserProfile()?['name'] as String? ?? '';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts.first[0].toUpperCase();
    return '?';
  }

  String get _language {
    final lang = SwarajCacheService.getUserProfile()?['language'] as String? ?? 'en';
    return lang == 'hi' ? 'hi' : 'en';
  }

  @override
  void dispose() {
    _inputController.dispose();
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

  Future<void> _sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final result = await ref.read(apiClientProvider).post('/ai/explain', {
        'question': text,
        'language': _language,
      }) as Map<String, dynamic>;

      final explanation = result['explanation'] as String? ?? '';
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: explanation, isUser: false, timestamp: DateTime.now()));
      });
    } catch (e) {
      if (!mounted) return;
      String errMsg = 'Sorry, AI is unavailable right now. Try again shortly.';
      if (e is ApiException && e.statusCode == 429) {
        errMsg = 'Rate limit reached — try again in a minute.';
      } else if (e is ApiException && e.statusCode == 503) {
        errMsg = 'AI provider not configured on this server.';
      }
      setState(() {
        _messages.add(ChatMessage(text: errMsg, isUser: false, timestamp: DateTime.now()));
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'SWARAJ',
              style: SwarajTypography.headline(
                  fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: SwarajColors.saffron.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100),
                border:
                    Border.all(color: SwarajColors.saffron.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 10, color: SwarajColors.saffron),
                  const SizedBox(width: 4),
                  Text(
                    'AI ACTIVE',
                    style: SwarajTypography.mono(
                        fontSize: 8,
                        color: SwarajColors.saffron,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: SwarajColors.navy,
              child: Text(
                _userInitials,
                style: SwarajTypography.mono(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              color: SwarajColors.navy.withValues(alpha: 0.06), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isLoading ? 1 : 0) + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INSTITUTIONAL INTELLIGENCE',
                          style: SwarajTypography.mono(
                              fontSize: 11, color: SwarajColors.slateLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Swaraj AI Assistant',
                          style: SwarajTypography.headline(
                              fontSize: 32, fontWeight: FontWeight.w800),
                        ),
                        const Divider(height: 24),
                        Text(
                          'Democratizing legal clarity. Ask for simple explanations of constitutional articles, civic duties, or parliamentary procedures.',
                          style: SwarajTypography.body(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                final msgIndex = index - 1;
                if (msgIndex == _messages.length && _isLoading) {
                  return _buildTypingIndicatorCard();
                }

                final msg = _messages[msgIndex];
                return _buildMessageCard(msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildSuggestionChip('Explain Article 14', Icons.article),
                const SizedBox(width: 8),
                _buildSuggestionChip('Who is the Speaker?', Icons.person),
                const SizedBox(width: 8),
                _buildSuggestionChip('What is a Money Bill?', Icons.receipt_long),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(
                      color: SwarajColors.navy.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: _sendMessage,
                    enabled: !_isLoading,
                    style: SwarajTypography.body(
                        fontSize: 15, color: SwarajColors.navy),
                    decoration: InputDecoration(
                      hintText: 'Ask about any civic term...',
                      hintStyle:
                          SwarajTypography.body(color: SwarajColors.outline),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 12),
                    ),
                  ),
                ),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: SwarajColors.navy),
                        ),
                      )
                    : IconButton(
                        onPressed: () => _sendMessage(_inputController.text),
                        icon: const Icon(Icons.send, color: SwarajColors.navy),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, IconData icon) {
    return InputChip(
      onPressed: _isLoading ? null : () => _sendMessage(text),
      avatar: Icon(icon, size: 14, color: SwarajColors.slate),
      label: Text(text),
      labelStyle:
          SwarajTypography.body(fontSize: 13, color: SwarajColors.slate),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: SwarajColors.navy.withValues(alpha: 0.1)),
      ),
    );
  }

  Widget _buildMessageCard(ChatMessage msg) {
    final bool isUser = msg.isUser;
    final timeStr =
        "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser ? SwarajColors.navy : Colors.white,
              border: isUser
                  ? null
                  : Border.all(
                      color: SwarajColors.navy.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isUser ? 12 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  Row(
                    children: [
                      Text(
                        'EXPLAIN SIMPLY',
                        style: SwarajTypography.mono(
                            fontSize: 10, color: SwarajColors.saffron),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '|',
                        style: SwarajTypography.mono(
                            fontSize: 10, color: SwarajColors.outlineVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  msg.text,
                  style: SwarajTypography.body(
                    fontSize: 15,
                    color: isUser ? Colors.white : SwarajColors.navy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (isUser)
            Text(
              '$timeStr | USER',
              style: SwarajTypography.mono(
                  fontSize: 10, color: SwarajColors.slateLight),
            )
          else
            Row(
              children: [
                Text(
                  '$timeStr | SWARAJ AI',
                  style: SwarajTypography.mono(
                      fontSize: 10, color: SwarajColors.slateLight),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: msg.text));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied to clipboard',
                            style: SwarajTypography.mono(
                                color: Colors.white, fontSize: 13)),
                        backgroundColor: SwarajColors.navy,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.copy,
                          size: 12, color: SwarajColors.slateLight),
                      const SizedBox(width: 4),
                      Text('Copy',
                          style: SwarajTypography.mono(
                              fontSize: 10, color: SwarajColors.slateLight)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicatorCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CircleAvatar(
                radius: 3,
                backgroundColor: SwarajColors.navy.withValues(alpha: 0.4),
              ),
            );
          }),
        ),
      ),
    );
  }
}
