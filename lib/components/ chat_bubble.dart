import 'package:chatapp/services/chat/chat_service.dart';
import 'package:chatapp/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageId,
    required this.userId,
  });

  // show options function
  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // report messaage button
              ListTile(
                leading: Icon(Icons.flag),
                title: Text('Report'),
                onTap: () {
                  // report user
                  Navigator.pop(context);
                  _reportMessage(context, messageId, userId);
                },
              ),

              // block user button
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Block'),
                onTap: () {
                  // block user
                  Navigator.pop(context);
                  _blockUser(context, userId);
                },
              ),

              // cancel button
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () =>
                    // cancel
                    Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // light vs dark mode for correct bubble
    bool isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          // show options
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser
              ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade500)
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Text(
          message,
          style: TextStyle(
            color: isCurrentUser
                ? Colors.white
                : (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  // report messge
  void _reportMessage(BuildContext context, String messageId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Message'),
        content: Text('Are you sure you want to report this message?'),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),

          // report button
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Message reported')));
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  // block user
  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text('Are you sure you want to Block this User?'),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),

          // block button
          TextButton(
            onPressed: () {
              ChatService().blockUser(userId);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('User blocked!')));
            },
            child: Text('Block'),
          ),
        ],
      ),
    );
  }
}
