import 'package:flutter/material.dart';

import '../../core/services/ai_service.dart';
import '../../models/chat_message_model.dart';
import 'chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final AIService aiService = AIService();

  final List<ChatMessageModel> messages = [];

  bool isTyping = false;

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,

          duration: const Duration(milliseconds: 300),

          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final message = messageController.text.trim();

    if (message.isEmpty) return;

    setState(() {
      messages.add(ChatMessageModel(message: message, isUser: true));

      isTyping = true;
    });

    messageController.clear();

    scrollToBottom();

    try {
      final aiResponse = await aiService.sendMessage(message);

      setState(() {
        isTyping = false;

        messages.add(ChatMessageModel(message: aiResponse, isUser: false));
      });
    } catch (e) {
      setState(() {
        isTyping = false;

        messages.add(
          ChatMessageModel(message: 'Something went wrong.', isUser: false),
        );
      });
    }

    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rupixa AI')),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,

              padding: const EdgeInsets.all(16),

              itemCount: messages.length,

              itemBuilder: (context, index) {
                final message = messages[index];

                return ChatBubble(
                  message: message.message,

                  isUser: message.isUser,
                );
              },
            ),
          ),

          if (isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 10),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text('AI is typing...'),
              ),
            ),

          Container(
            padding: const EdgeInsets.all(12),

            decoration: const BoxDecoration(
              color: Colors.white,

              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,

                    textInputAction: TextInputAction.send,

                    onSubmitted: (_) {
                      sendMessage();
                    },

                    decoration: InputDecoration(
                      hintText: 'Ask anything...',

                      filled: true,

                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),

                        borderSide: BorderSide.none,
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 24,

                  child: IconButton(
                    onPressed: sendMessage,

                    icon: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
