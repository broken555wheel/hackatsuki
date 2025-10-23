import 'package:flutter/material.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/pages/ai_chat_page.dart';
import 'package:provider/provider.dart';

class ChatListDrawer extends StatelessWidget {
  const ChatListDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.lightGreen1,
      child: Consumer2<ChatProvider, MessageProvider>(
        builder: (context, chatProvider, messageProvider, _) {
          final chats = chatProvider.chats;
          final totalItems = chats.length + (chatProvider.hasMoreChats ? 1 : 0);

          Widget content;

          if (chatProvider.isLoading && chats.isEmpty) {
            content = const Center(child: CircularProgressIndicator());
          } else if (chatProvider.error != null) {
            content = Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading chats: ${chatProvider.error}',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                ),
              ),
            );
          } else if (chats.isEmpty) {
            content = const Center(child: Text('No chats found.'));
          } else {
            content = ListView.builder(
              itemCount: totalItems,
              itemBuilder: (context, index) {
                if (index == chats.length) {
                  if (chatProvider.hasMoreChats) {
                    chatProvider.loadChats();
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final chat = chats[index];
                final isActive = chatProvider.activeChat?.id == chat.id;
                final isLoading = messageProvider.isChatLoading(chat.id ?? '');
                final hasMessages = messageProvider
                    .getMessagesForChat(chat.id ?? '')
                    .isNotEmpty;

                return ListTile(
                  title: Text(
                    chat.title?.isNotEmpty == true
                        ? chat.title!
                        : 'Chat ${index + 1}',
                  ),
                  subtitle: hasMessages
                      ? Text(
                          '${messageProvider.getMessagesForChat(chat.id ?? '').length} messages',
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (isActive)
                        Icon(Icons.check, color: AppTheme.green2, size: 20),
                    ],
                  ),
                  onTap: () async {
                    try {
                      chatProvider.setActiveChat(chat);
                      await messageProvider.setActiveChat(chat.id!);

                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatPage()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error switching chat: $e')),
                      );
                    }
                  },
                  onLongPress: isLoading
                      ? () {
                          messageProvider.cancelStreamForChat(chat.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cancelled response')),
                          );
                        }
                      : null,
                );
              },
            );
          }

          return Column(
            children: [
              const DrawerHeader(margin: EdgeInsets.only(bottom: 0),child: Text('Your Chats'),),
              Expanded(child: content),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Chat'),
                onTap: () async {
                  try {
                    final newChat = await chatProvider.createNewChat();
                    if (newChat != null && newChat.id != null) {
                      chatProvider.setActiveChat(newChat);
                      messageProvider.setActiveChat(newChat.id!);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatPage()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create a new chat: $e'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
