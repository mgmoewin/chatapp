import 'package:chatapp/components/user_tile.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/components/my_drawer.dart';
import 'package:chatapp/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // chat & auth service
  final AuthService _auth = AuthService();
  final ChatService _chat = ChatService();

  // logout function
  void logout() {
    // get auth service and call sign out
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('HOME'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        // foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          // logout button
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chat.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        // error handling and data display
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        // loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        // list of users
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // build each user list item
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // display all user expect for the current logged in user
    if (userData['email'] != _auth.getCurrentUser()!.email) {
      {
        //
        return UserTile(
          text: userData['email'],
          onTap: () async {
            // mark all messages in this chat page as read
            await _chat.markMessageAsRead(userData['uid']);

            // tapped on a user ->  go to chat page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receriverEmail: userData['email'],
                  receiverId: userData['uid'],
                ),
              ),
            );
          },
          unreadMessagesCount: userData['unreadCount'],
        );
      }
    } else {
      return Container();
    }
  }
}
