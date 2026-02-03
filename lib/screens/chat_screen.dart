import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provdier.dart';
import '../widgets/message-bubble.dart';
import '../config/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty) return;

    final content = _chatController.text.trim();
    _chatController.clear();

    await _chatProvider.sendMessage(content);
    _scrollToBottom();
  }

  Future<void> _showClearDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _chatProvider.clearChat();
    }
  }

  void _toggleTheme() {
    _chatProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powered by Gemini',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: _toggleTheme,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      message: provider.messages[index],
                    );
                  },
                );
              },
            ),
          ),

          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              if (!provider.isLoading) return const SizedBox.shrink();
              return _buildLoadingIndicator();
            },
          ),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start a Conversation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Ask me anything! I\'m here to help you learn and explore.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('Explain Flutter'),
              _buildSuggestionChip('Write code'),
              _buildSuggestionChip('Help me learn'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.lightbulb_outline, size: 18),
      onPressed: () {
        _chatController.text = label;
        _sendMessage();
      },
      backgroundColor: AppTheme.surfaceColor,
      side: BorderSide(color: AppTheme.accentColor.withOpacity(0.3)),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(width: 16),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'AI is thinking...',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.secondaryColor, AppTheme.accentColor],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(25),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }
}