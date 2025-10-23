import 'package:chatapp/components/user_tile.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class BlockUserPage extends StatelessWidget {
  final AuthService authService = AuthService();
  final ChatService chatService = ChatService();

  BlockUserPage({super.key});

  // show a unblock box
  void _showUnblockBox(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Unblock User"),
        content: Text("Are you sure you want to unblock this user?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          //unblock button
          TextButton(
            onPressed: () {
              chatService.unblockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("User unblocked")));
            },
            child: Text("Unblock"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // get curretn user id
    final userId = authService.getCurrentUser()!.uid;

    // UI
    return Scaffold(
      appBar: AppBar(
        title: Text("BLOCKED USER"),
        centerTitle: true,
        actions: [],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getBlockUserStream(userId),
        builder: (context, snapshot) {
          // error..
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          // loading...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final blockUsers = snapshot.data ?? [];

          // no block user
          if (blockUsers.isEmpty) {
            return const Center(child: Text('No blocked user'));
          }

          // load complete and show block user list stream
          return ListView.builder(
            itemCount: blockUsers.length,
            itemBuilder: (context, index) {
              final user = blockUsers[index];
              return UserTile(
                text: user['email'],
                onTap: () => _showUnblockBox(context, user['uid']),
              );
            },
          );
        },
      ),
    );
  }
}
