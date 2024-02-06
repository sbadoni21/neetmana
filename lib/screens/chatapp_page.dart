import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/chatpage.dart';
import 'package:matrimonial/services/user_service/chat_service.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/chat_cards.dart';
import 'package:matrimonial/widget/user_card.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

class ChatAppPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider);
    final chatService = ref.watch(chatServiceProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('My Contacts', style: myTextStylefontsize24BGCOLOR),
      ),
      body: FutureBuilder<List<User>>(
        future: chatService.getMyContacts(currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            otherUser: user,
                          ),
                        ),
                      );
                    },
                    child: ChatCard(
                      user: user,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
