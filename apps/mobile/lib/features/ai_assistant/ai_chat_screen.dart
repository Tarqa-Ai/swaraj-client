import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? heading;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.heading,
    required this.timestamp,
  });
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'What is a Quorum?',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      text:
          'Think of a Quorum as the "Minimum Attendance Rule."\n\nFor any meeting of the Parliament (Lok Sabha or Rajya Sabha) to be official and valid, at least 1/10th of the total members must be present. If fewer people show up, the Speaker can suspend the meeting because there aren\'t enough people to represent the nation fairly.',
      isUser: false,
      heading: 'Explain Simply',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
  ];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

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

  void _showMockToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: SwarajColors.navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: query,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      String reply = '';
      final String q = query.toLowerCase();

      if (q.contains('article 14')) {
        reply =
            'Article 14 guarantees Equality before Law.\n\nIt means two things:\n1. No person is above the law — whether you\'re a citizen, minister, or the PM.\n2. Equal protection — the State must treat people in similar circumstances equally.\n\nHowever, "reasonable classification" is allowed — the State can treat different groups differently if there\'s a logical basis for it.';
      } else if (q.contains('speaker')) {
        reply =
            'The Speaker of the Lok Sabha is the presiding officer who maintains order, decides who speaks, and interprets rules.\n\nThink of the Speaker as the "referee" of Parliament. They don\'t usually vote, except to break a tie. They must remain impartial once elected.';
      } else if (q.contains('money bill')) {
        reply =
            'A Money Bill deals with taxation, government spending, or borrowing.\n\nKey rules:\n• Can only be introduced in Lok Sabha\n• Speaker decides if a bill is a Money Bill\n• Rajya Sabha can suggest changes within 14 days, but Lok Sabha can ignore them.\n\nThis gives Lok Sabha (the elected house) more power over the nation\'s finances.';
      } else {
        reply =
            'That\'s a great question about "$query".\n\nThis is a concept rooted in Indian civic governance. In simple terms, it relates to the fundamental principles that guide how our democracy operates, ensuring accountability, transparency, and citizen participation.\n\nWould you like me to explore a specific aspect of this topic in more detail?';
      }

      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: reply,
          isUser: false,
          heading: 'Explain Simply',
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      appBar: AppBar(
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
                border: Border.all(
                    color: SwarajColors.saffron.withValues(alpha: 0.2)),
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
                'AK',
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
              itemCount: _messages.length + (_isTyping ? 1 : 0) + 1,
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

                int msgIndex = index - 1;
                if (msgIndex == _messages.length && _isTyping) {
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
                _buildSuggestionChip(
                    'What is a Money Bill?', Icons.receipt_long),
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
                IconButton(
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
      onPressed: () => _sendMessage(text),
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
                if (!isUser && msg.heading != null) ...[
                  Row(
                    children: [
                      Text(
                        msg.heading!.toUpperCase(),
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
                  onTap: () => _showMockToast('Copied to clipboard'),
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
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _showMockToast('Share link created'),
                  child: Row(
                    children: [
                      const Icon(Icons.share,
                          size: 12, color: SwarajColors.slateLight),
                      const SizedBox(width: 4),
                      Text('Share',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
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
        ],
      ),
    );
  }
}
