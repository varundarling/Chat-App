import 'package:chat_app/widgets/message_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatsSnapshots) {
        if (chatsSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatsSnapshots.hasData || chatsSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages Found...'),
          );
        }

        if (chatsSnapshots.hasError) {
          return const Center(
            child: Text('Something went Wrong....'),
          );
        }

        final loadedMessages = chatsSnapshots.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 20,
            left: 10,
            right: 10,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUSerId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessageUSerId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
